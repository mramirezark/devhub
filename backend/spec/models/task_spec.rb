require "rails_helper"

RSpec.describe Task, type: :model do
  let(:project) { Project.create!(name: "Spec Project") }

  describe "status change callbacks" do
    it "enqueues ActivityLoggerJob when status changes" do
      task = project.tasks.create!(title: "Write docs", status: :pending)

      expect do
        task.update!(status: :completed)
      end.to have_enqueued_job(ActivityLoggerJob).with(task.id, "pending", "completed")
    end

    it "does not enqueue ActivityLoggerJob when other attributes change" do
      task = project.tasks.create!(title: "Write docs", status: :pending)

      expect do
        task.update!(title: "Write thorough docs")
      end.not_to have_enqueued_job(ActivityLoggerJob)
    end
  end
end

