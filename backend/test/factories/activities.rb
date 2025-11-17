FactoryBot.define do
  factory :activity do
    association :record, factory: :task, strategy: :create
    sequence(:action) { |n| "action_#{n}" }

    trait :for_task do
      association :record, factory: :task, strategy: :create
    end

    trait :for_project do
      association :record, factory: :project, strategy: :create
    end

    trait :created do
      action { "created" }
    end

    trait :updated do
      action { "updated" }
    end

    trait :deleted do
      action { "deleted" }
    end

    trait :status_changed do
      action { "status_changed" }
    end
  end
end
