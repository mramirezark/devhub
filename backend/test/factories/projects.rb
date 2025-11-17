FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { nil }

    trait :with_description do
      description { "A detailed project description" }
    end

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 3, project: project)
      end
    end

    trait :with_completed_tasks do
      after(:create) do |project|
        create_list(:task, 2, :completed, project: project)
      end
    end
  end
end
