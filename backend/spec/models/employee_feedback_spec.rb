require 'rails_helper'

RSpec.describe EmployeeFeedback, type: :model do
  let!(:file) { ImportFile.create(name: "test.csv") }

  describe "Cálculos de Métricas" do
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

    it "calcula o eNPS corretamente" do
      feedbacks = file.employee_feedbacks
      p = feedbacks.where(enps: 9..10).count.to_f / feedbacks.count
      d = feedbacks.where(enps: 0..6).count.to_f / feedbacks.count
      enps_score = ((p - d) * 100).round(2)
      
      expect(enps_score).to eq(0.0)
    end

    it "valida se a favorabilidade ignora neutros" do
      favorable_count = file.employee_feedbacks.where(feedback: 4..5).count
      expect(favorable_count).to eq(3)
    end
  end
end