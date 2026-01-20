FactoryBot.define do
  factory :employee_feedback do
    association :import_file 
    
    nome { "Colaborador Teste" }
    email { "teste#{rand(1000)}@empresa.com" }
    area { ["TI", "RH", "Vendas", "Financeiro"].sample }
    cargo { "Analista" }
    localidade { "São Paulo" }
    
    enps { rand(0..10) }
    feedback { rand(1..5) }
    interesse_no_cargo { rand(1..5) }
    contribuicao { rand(1..5) }
    aprendizado_desenvolvimento { rand(1..5) }
    interacao_gestor { rand(1..5) }
    clareza_carreira { rand(1..5) }
    expectativa_permanencia { rand(1..5) }
    
    enps_aberta { "Gosto muito da cultura da empresa." }
    comentarios_feedback { "O feedback foi construtivo." }
    data_da_resposta { Time.now.strftime("%d/%m/%Y") }
    
    n1_diretoria { "Diretoria de Operações" }
    n2_gerencia { "Gerência Técnica" }
  end
end