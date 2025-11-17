ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"

require "rails/test_help"
require "active_job/test_helper"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  include ActiveJob::TestHelper
  include FactoryBot::Syntax::Methods

  setup do
    ActiveJob::Base.queue_adapter = :test
  end
end
