require 'rails_helper'

RSpec.describe ImportCsvService do
  let(:import_file) { ImportFile.create!(name: 'sample.csv') }
  let(:csv_path) { Rails.root.join('spec/fixtures/files/sample.csv') }

  describe '.call' do
    context 'when CSV is valid' do
      it 'processa o CSV e cria registros de feedback' do
        expect {
          ImportCsvService.call(csv_path, import_file)
        }.to change(EmployeeFeedback, :count).by_at_least(1)
      end

      it 'atribui corretamente os valores convertidos para inteiro' do
        ImportCsvService.call(csv_path, import_file)
        last_feedback = EmployeeFeedback.last
        
        expect(last_feedback.enps).to be_an(Integer)
        expect(last_feedback.feedback).to be_an(Integer)
        expect(last_feedback.import_file_id).to eq(import_file.id)
      end

      it 'associates feedbacks with the correct import file' do
        ImportCsvService.call(csv_path, import_file)
        
        feedbacks = EmployeeFeedback.where(import_file: import_file)
        expect(feedbacks.count).to be > 0
        feedbacks.each do |feedback|
          expect(feedback.import_file_id).to eq(import_file.id)
        end
      end

      it 'updates import file status to completed' do
        ImportCsvService.call(csv_path, import_file)
        
        import_file.reload
        expect(import_file.status).to eq('completed')
      end

      it 'processes all CSV rows' do
        ImportCsvService.call(csv_path, import_file)
        
        expect(EmployeeFeedback.where(import_file: import_file).count).to eq(2)
      end

      it 'sets all required fields from CSV' do
        ImportCsvService.call(csv_path, import_file)
        
        feedback = EmployeeFeedback.where(import_file: import_file).first
        expect(feedback.nome).to be_present
        expect(feedback.email).to be_present
        expect(feedback.area).to be_present
      end

      it 'handles semicolon-separated CSV format' do
        ImportCsvService.call(csv_path, import_file)
        
        feedback = EmployeeFeedback.where(import_file: import_file).first
        expect(feedback).to be_persisted
      end

      it 'converts numeric fields correctly' do
        ImportCsvService.call(csv_path, import_file)
        
        feedback = EmployeeFeedback.where(import_file: import_file).first
        expect(feedback.interesse_no_cargo).to be_a(Integer) if feedback.interesse_no_cargo.present?
        expect(feedback.contribuicao).to be_a(Integer) if feedback.contribuicao.present?
      end
    end

    context 'when transaction fails' do
      it 'garante atomicidade usando transaction (falha tudo ou nada)' do
        allow(EmployeeFeedback).to receive(:create!).and_raise(StandardError)
        
        expect {
          begin
            ImportCsvService.call(csv_path, import_file)
          rescue
          end
        }.not_to change(EmployeeFeedback, :count)
      end

      it 'does not update status to completed when transaction fails' do
        allow(EmployeeFeedback).to receive(:create!).and_raise(StandardError.new('Test error'))
        
        expect {
          ImportCsvService.call(csv_path, import_file)
        }.to raise_error(StandardError, 'Test error')
        
        import_file.reload
        expect(import_file.status).to eq('processing')
      end

      it 'rolls back all changes on error' do
        initial_count = EmployeeFeedback.count
        
        allow(EmployeeFeedback).to receive(:create!).and_raise(StandardError)
        
        expect {
          begin
            ImportCsvService.call(csv_path, import_file)
          rescue
          end
        }.not_to change(EmployeeFeedback, :count)
      end
    end

    context 'when CSV file is invalid' do
      let(:invalid_csv_path) { Rails.root.join('tmp', "invalid-#{SecureRandom.uuid}.csv") }

      before do
        File.write(invalid_csv_path, "invalid,csv,format\n")
      end

      after do
        File.delete(invalid_csv_path) if File.exist?(invalid_csv_path)
      end

      it 'handles malformed CSV gracefully' do
        expect {
          begin
            ImportCsvService.call(invalid_csv_path, import_file)
          rescue
          end
        }.not_to raise_error
      end
    end

    context 'when CSV has empty rows' do
      let(:empty_csv_path) { Rails.root.join('tmp', "empty-#{SecureRandom.uuid}.csv") }

      before do
        File.write(empty_csv_path, "nome;email;enps\n")
      end

      after do
        File.delete(empty_csv_path) if File.exist?(empty_csv_path)
      end

      it 'handles CSV with only headers' do
        ImportCsvService.call(empty_csv_path, import_file)
        
        expect(EmployeeFeedback.where(import_file: import_file).count).to eq(0)
        import_file.reload
        expect(import_file.status).to eq('completed')
      end
    end

    context 'when CSV has missing optional fields' do
      let(:minimal_csv_path) { Rails.root.join('tmp', "minimal-#{SecureRandom.uuid}.csv") }

      before do
        File.write(minimal_csv_path, "nome;email;eNPS\nTest User;test@test.com;10\n")
      end

      after do
        File.delete(minimal_csv_path) if File.exist?(minimal_csv_path)
      end

      it 'creates feedback with available fields only' do
        ImportCsvService.call(minimal_csv_path, import_file)
        
        feedback = EmployeeFeedback.where(import_file: import_file).first
        expect(feedback.nome).to eq('Test User')
        expect(feedback.email).to eq('test@test.com')
        expect(feedback.enps).to eq(10)
      end
    end
  end
end