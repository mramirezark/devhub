module Admin
  class Engine < ::Rails::Engine
    isolate_namespace Admin

    initializer "admin.load_paths" do |app|
      app.config.eager_load_paths << root.join("app")
    end
  end
end
