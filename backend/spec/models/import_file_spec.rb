require 'rails_helper'

RSpec.describe ImportFile, type: :model do
  it { should have_many(:employee_feedbacks).dependent(:destroy) }
  it { should validate_presence_of(:name) }

  describe 'associations' do
    it 'deleta feedbacks associados ao ser removido' do
      import = ImportFile.create!(name: 'test.csv')
      import.employee_feedbacks.create!(nome: 'Bruno', email: 'bruno@test.com', enps: 10, feedback: 5)
      
      expect { import.destroy }.to change(EmployeeFeedback, :count).by(-1)
    end

    it 'retorna feedbacks associados' do
      import = create(:import_file)
      feedback1 = create(:employee_feedback, import_file: import)
      feedback2 = create(:employee_feedback, import_file: import)

      expect(import.employee_feedbacks).to include(feedback1, feedback2)
    end
  end

  describe 'validations' do
    context 'when name is present' do
      it 'validates CSV file extension' do
        import = ImportFile.new(name: 'test.csv')
        expect(import).to be_valid
      end

      it 'rejects non-CSV file extensions' do
        import = ImportFile.new(name: 'test.pdf')
        expect(import).not_to be_valid
        expect(import.errors[:name]).to include('deve ser um arquivo no formato CSV')
      end

      it 'validates case insensitive CSV extension' do
        import = ImportFile.new(name: 'test.CSV')
        expect(import).to be_valid
      end

      it 'validates csv extension with uppercase' do
        import = ImportFile.new(name: 'test.Csv')
        expect(import).to be_valid
      end
    end

    context 'when name is blank' do
      it 'requires name to be present' do
        import = ImportFile.new(name: '')
        expect(import).not_to be_valid
        expect(import.errors[:name]).to be_present
      end

      it 'requires name to not be nil' do
        import = ImportFile.new(name: nil)
        expect(import).not_to be_valid
      end
    end
  end

  describe 'enum status' do
    it 'has processing status as default' do
      import = ImportFile.new(name: 'test.csv')
      expect(import.status).to eq('processing')
    end

    it 'can be set to completed status' do
      import = create(:import_file, status: :completed)
      expect(import.status).to eq('completed')
    end

    it 'can be set to failed status' do
      import = create(:import_file, status: :failed)
      expect(import.status).to eq('failed')
    end

    it 'can query by status' do
      import1 = create(:import_file, status: :processing)
      import2 = create(:import_file, status: :completed)
      import3 = create(:import_file, status: :failed)

      expect(ImportFile.processing).to include(import1)
      expect(ImportFile.completed).to include(import2)
      expect(ImportFile.failed).to include(import3)
    end
  end

  describe '#feedbacks_count' do
    context 'when there are no feedbacks' do
      it 'returns zero' do
        import = create(:import_file)
        expect(import.feedbacks_count).to eq(0)
      end
    end

    context 'when there are feedbacks' do
      it 'returns the correct count' do
        import = create(:import_file)
        create_list(:employee_feedback, 3, import_file: import)

        expect(import.feedbacks_count).to eq(3)
      end

      it 'updates count after adding feedbacks' do
        import = create(:import_file)
        expect(import.feedbacks_count).to eq(0)

        create(:employee_feedback, import_file: import)
        expect(import.feedbacks_count).to eq(1)

        create(:employee_feedback, import_file: import)
        expect(import.feedbacks_count).to eq(2)
      end

      it 'updates count after deleting feedbacks' do
        import = create(:import_file)
        feedback1 = create(:employee_feedback, import_file: import)
        feedback2 = create(:employee_feedback, import_file: import)

        expect(import.feedbacks_count).to eq(2)

        feedback1.destroy
        expect(import.feedbacks_count).to eq(1)

        feedback2.destroy
        expect(import.feedbacks_count).to eq(0)
      end
    end
  end
end