# frozen_string_literal: true

# Ensure engine services are loaded
Rails.application.config.after_initialize do
  # Load Core engine services (concerns first, then services)
  core_services_path = Rails.root.join("app/engines/core/app/services")
  if core_services_path.exist?
    # Load concerns first
    concerns_path = core_services_path.join("concerns")
    if concerns_path.exist?
      Dir.glob(concerns_path.join("*.rb")).sort.each do |file|
        require_dependency file.to_s
      end
    end
    # Then load services
    Dir.glob(core_services_path.join("*.rb")).sort.each do |file|
      require_dependency file.to_s
    end
  end

  # Load Admin engine services (concerns first, then services)
  admin_services_path = Rails.root.join("app/engines/admin/app/services")
  if admin_services_path.exist?
    # Load concerns first
    concerns_path = admin_services_path.join("concerns")
    if concerns_path.exist?
      Dir.glob(concerns_path.join("*.rb")).sort.each do |file|
        require_dependency file.to_s
      end
    end
    # Then load services
    Dir.glob(admin_services_path.join("*.rb")).sort.each do |file|
      require_dependency file.to_s
    end
  end
end
