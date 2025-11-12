module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core

    initializer "core.load_paths" do |app|
      app.config.eager_load_paths << root.join("app")
    end
  end
end
