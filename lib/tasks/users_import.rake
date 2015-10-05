namespace :users do
  desc "Import users from a spreadsheet"
  task :import, [:tenant_id] => :environment do |task, args|
    Apartment::Tenant.switch "tenant#{args.tenant_id}"

    tenant = Admin::Tenant.find(args.tenant_id) # may or may not be useful

    UserImport.create!(user_import_file: ENV['USERS_IMPORT_FILE'])
  end

end
