FactoryBot.define do
  factory :employee_feedback do
    nome { Faker::Name.name }
    email { Faker::Internet.email }
    area { ["TI", "RH", "Vendas", "Marketing"].sample }
    enps { rand(0..10) }
    feedback { rand(1..5) }
    data_da_resposta { Time.current }
  end
end