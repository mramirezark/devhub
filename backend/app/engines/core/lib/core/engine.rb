module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core

    # Rails automatically loads app/ directory
    # Explicitly configure autoload paths for services and concerns
    config.autoload_paths << root.join("app", "services")
    config.eager_load_paths << root.join("app", "services")
    config.autoload_paths << root.join("app", "services", "concerns")
    config.eager_load_paths << root.join("app", "services", "concerns")
  end
end
