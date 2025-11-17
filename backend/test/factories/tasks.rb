FactoryBot.define do
  factory :task do
    association :project
    sequence(:title) { |n| "Task #{n}" }
    status { :pending }
    description { nil }
    due_at { nil }
    assignee { nil }

    trait :pending do
      status { :pending }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    trait :with_description do
      description { "A detailed task description" }
    end

    trait :with_due_date do
      due_at { 1.week.from_now }
    end

    trait :assigned do
      association :assignee, factory: :user
    end

    trait :with_activities do
      after(:create) do |task|
        create_list(:activity, 3, record: task)
      end
    end
  end
end
