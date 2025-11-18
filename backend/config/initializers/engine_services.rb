# frozen_string_literal: true

# Ensure engine services are loaded before each request
Rails.application.config.to_prepare do
  # Helper method to load services for an engine
  load_engine_services = lambda do |engine_name|
    services_path = Rails.root.join("app/engines/#{engine_name}/app/services")
    return unless services_path.exist?

    # Load concerns first
    concerns_path = services_path.join("concerns")
    if concerns_path.exist?
      Dir.glob(concerns_path.join("*.rb")).sort.each do |file|
        require_dependency file.to_s
      end
    end

    # Then load services
    Dir.glob(services_path.join("*.rb")).sort.each do |file|
      require_dependency file.to_s
    end
  end

  # Load services for all engines
  %w[core admin].each do |engine_name|
    load_engine_services.call(engine_name)
  end
end
