FactoryBot.define do
  factory :import_file do
    name { "pesquisa_engajamento_#{Time.now.to_i}.csv" }
    
    trait :with_feedbacks do
      after(:create) do |import_file|
        create_list(:employee_feedback, 3, import_file: import_file)
      end
    end
  end
end