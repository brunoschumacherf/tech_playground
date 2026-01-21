require 'rails_helper'

RSpec.describe EmployeeFeedback, type: :model do
  let!(:file) { ImportFile.create(name: "test.csv") }

  describe 'associations' do
    it { should belong_to(:import_file) }

    it 'belongs to an import file' do
      feedback = create(:employee_feedback, import_file: file)
      expect(feedback.import_file).to eq(file)
    end

    it 'cannot exist without an import file' do
      feedback = EmployeeFeedback.new(
        nome: 'Test',
        email: 'test@test.com',
        enps: 10
      )
      expect(feedback).not_to be_valid
    end
  end

  describe 'Cálculos de Métricas' do
    before do
      [10, 9, 7, 5, 0].each do |score|
        EmployeeFeedback.create!(
          import_file: file,
          enps: score,
          feedback: score > 5 ? 5 : 2,
          nome: "Test User", 
          email: "test#{score}@test.com"
        )
      end
    end

    it 'calcula o eNPS corretamente' do
      feedbacks = file.employee_feedbacks
      p = feedbacks.where(enps: 9..10).count.to_f / feedbacks.count
      d = feedbacks.where(enps: 0..6).count.to_f / feedbacks.count
      enps_score = ((p - d) * 100).round(2)
      
      expect(enps_score).to eq(0.0)
    end

    it 'valida se a favorabilidade ignora neutros' do
      favorable_count = file.employee_feedbacks.where(feedback: 4..5).count
      expect(favorable_count).to eq(3)
    end

    context 'when calculating eNPS with different scores' do
      before do
        file.employee_feedbacks.destroy_all
        [10, 10, 10, 0, 0].each do |score|
          EmployeeFeedback.create!(
            import_file: file,
            enps: score,
            feedback: 5,
            nome: "Test User", 
            email: "test#{score}@test.com"
          )
        end
      end

      it 'calculates correct eNPS for promoters and detractors' do
        feedbacks = file.employee_feedbacks
        p = feedbacks.where(enps: 9..10).count.to_f / feedbacks.count
        d = feedbacks.where(enps: 0..6).count.to_f / feedbacks.count
        enps_score = ((p - d) * 100).round(2)
        
        expect(enps_score).to eq(20.0)
      end
    end

    context 'when calculating favorability' do
      before do
        file.employee_feedbacks.destroy_all
        [5, 5, 4, 3, 2].each do |score|
          EmployeeFeedback.create!(
            import_file: file,
            feedback: score,
            enps: 10,
            nome: "Test User", 
            email: "test#{score}@test.com"
          )
        end
      end

      it 'counts only favorable feedbacks (4-5)' do
        favorable_count = file.employee_feedbacks.where(feedback: 4..5).count
        expect(favorable_count).to eq(3)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid employee feedback' do
      feedback = build(:employee_feedback)
      expect(feedback).to be_valid
    end

    it 'creates employee feedback with required attributes' do
      feedback = create(:employee_feedback)
      expect(feedback.nome).to be_present
      expect(feedback.email).to be_present
      expect(feedback.import_file).to be_present
    end
  end

  describe 'attributes' do
    it 'accepts all feedback attributes' do
      feedback = create(:employee_feedback,
        nome: 'John Doe',
        email: 'john@example.com',
        email_corporativo: 'john.corp@example.com',
        celular: '11999999999',
        area: 'TI',
        cargo: 'Analista',
        funcao: 'Profissional',
        localidade: 'São Paulo',
        tempo_de_empresa: 'Mais de 5 anos',
        genero: 'Masculino',
        geracao: 'Millennial',
        enps: 10,
        feedback: 5,
        interesse_no_cargo: 5,
        contribuicao: 5,
        aprendizado_desenvolvimento: 5,
        interacao_gestor: 5,
        clareza_carreira: 5,
        expectativa_permanencia: 5
      )

      expect(feedback.nome).to eq('John Doe')
      expect(feedback.email).to eq('john@example.com')
      expect(feedback.enps).to eq(10)
      expect(feedback.feedback).to eq(5)
    end
  end
end