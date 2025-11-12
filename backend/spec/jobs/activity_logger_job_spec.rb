require "rails_helper"

RSpec.describe ActivityLoggerJob, type: :job do
  let(:project) { Project.create!(name: "Spec Project") }
  let(:task) { project.tasks.create!(title: "Review PR", status: :pending) }

  it "creates an activity describing the status transition" do
    expect do
      described_class.perform_now(task.id, "pending", "completed")
    end.to change { task.activities.reload.count }.by(1)

    activity = task.activities.last
    expect(activity.action).to eq("Task status changed from Pending to Completed")
  end

  it "does nothing when the task cannot be found" do
    expect do
      described_class.perform_now(0, "pending", "completed")
    end.not_to change(Activity, :count)
  end
end

