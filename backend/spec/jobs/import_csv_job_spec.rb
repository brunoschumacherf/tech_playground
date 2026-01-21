require 'rails_helper'

RSpec.describe ImportCsvJob, type: :job do
  describe '#perform' do
    let(:import_file) { create(:import_file, status: :processing) }
    let(:csv_content) { "nome;email;enps\nTest;test@test.com;10\n" }
    let(:file_path) { Rails.root.join('tmp', "test-#{SecureRandom.uuid}.csv") }

    before do
      File.write(file_path, csv_content)
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    context 'when CSV import is successful' do
      it 'processes the CSV file and updates status to completed' do
        ImportCsvJob.new.perform(import_file.id, file_path.to_s)

        import_file.reload
        expect(import_file.status).to eq('completed')
        expect(import_file.employee_feedbacks.count).to be > 0
      end

      it 'deletes the temporary file after processing' do
        ImportCsvJob.new.perform(import_file.id, file_path.to_s)

        expect(File.exist?(file_path)).to be false
      end

      it 'creates employee feedback records from CSV' do
        expect {
          ImportCsvJob.new.perform(import_file.id, file_path.to_s)
        }.to change(EmployeeFeedback, :count).by_at_least(1)
      end
    end

    context 'when CSV import fails' do
      it 'updates status to failed when import fails' do
        allow(ImportCsvService).to receive(:call).and_raise(StandardError.new('Import failed'))

        ImportCsvJob.new.perform(import_file.id, file_path.to_s)

        import_file.reload
        expect(import_file.status).to eq('failed')
        expect(import_file.error_message).to eq('Import failed')
      end

      it 'deletes the temporary file even when import fails' do
        allow(ImportCsvService).to receive(:call).and_raise(StandardError.new('Import failed'))

        ImportCsvJob.new.perform(import_file.id, file_path.to_s)

        expect(File.exist?(file_path)).to be false
      end

      it 'does not create employee feedback records when import fails' do
        allow(ImportCsvService).to receive(:call).and_raise(StandardError.new('Import failed'))

        expect {
          ImportCsvJob.new.perform(import_file.id, file_path.to_s)
        }.not_to change(EmployeeFeedback, :count)
      end
    end

    context 'when import file does not exist' do
      it 'raises an error' do
        expect {
          ImportCsvJob.new.perform(999999, file_path.to_s)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when file path does not exist' do
      it 'handles missing file gracefully' do
        non_existent_path = Rails.root.join('tmp', "non-existent-#{SecureRandom.uuid}.csv")

        expect {
          ImportCsvJob.new.perform(import_file.id, non_existent_path.to_s)
        }.not_to raise_error

        import_file.reload
        expect(import_file.status).to eq('failed')
      end
    end
  end
end
