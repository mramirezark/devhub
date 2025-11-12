admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "admin123")
admin_name = ENV.fetch("ADMIN_NAME", "Administrator")

admin_user = User.find_or_initialize_by(email: admin_email)
admin_user.assign_attributes(
  name: admin_name,
  password: admin_password,
  password_confirmation: admin_password,
  admin: true
)

if admin_user.new_record? || admin_user.changed?
  admin_user.save!
  puts "Seeded admin user #{admin_email}"
else
  puts "Admin user #{admin_email} already present"
end
