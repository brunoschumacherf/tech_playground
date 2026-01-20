require 'rails_helper'

RSpec.describe ImportFile, type: :model do
  it { should have_many(:employee_feedbacks).dependent(:destroy) }
  it { should validate_presence_of(:name) }

  it 'deleta feedbacks associados ao ser removido' do
    import = ImportFile.create!(name: 'test.csv')
    import.employee_feedbacks.create!(nome: 'Bruno', email: 'bruno@test.com', enps: 10, feedback: 5)
    
    expect { import.destroy }.to change(EmployeeFeedback, :count).by(-1)
  end
end