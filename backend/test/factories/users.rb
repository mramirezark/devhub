FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :with_assigned_tasks do
      after(:create) do |user|
        project = create(:project)
        create_list(:task, 3, assignee: user, project: project)
      end
    end
  end
end
