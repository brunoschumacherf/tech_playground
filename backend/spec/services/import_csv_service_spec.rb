require 'rails_helper'

RSpec.describe ImportCsvService do
  let(:import_file) { ImportFile.create!(name: 'sample.csv') }
  let(:csv_path) { Rails.root.join('spec/fixtures/files/sample.csv') }

  describe '.call' do
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

    it 'garante atomicidade usando transaction (falha tudo ou nada)' do
      allow(EmployeeFeedback).to receive(:create!).and_raise(StandardError)
      
      expect {
        begin
          ImportCsvService.call(csv_path, import_file)
        rescue
        end
      }.not_to change(EmployeeFeedback, :count)
    end
  end
end