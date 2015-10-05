class Tenant::ClientImport < Tenant::UserImport

  SPREADSHEET_COLUMNS = %w(name email client_type phone_cell phone_landline phone_emergency phone_emergency_2 
      billing_house_number billing_street_name billing_line_2 billing_city billing_province_state billing_postal_zip 
      billing_country site_house_number site_street_name site_line_2 site_city site_province_state site_postal_zip 
      site_country site_alarm_code site_alarm_company site_alarm_safeword site_emergency_number site_zone)

  def save_and_invite_user(user)
    m = Apartment::Tenant.current_tenant.match(/\d+/)

    if user.persisted?
      # the user already exists in the database

      user.save!

      # tenant = Admin::Tenant.find(m[0])
      # user.invite! if tenant.try(:invite_clients_on_create)
    else
      user.skip_confirmation!

      user.save!
      # tenant = Admin::Tenant.find(m[0])
      # user.invite! if tenant.try(:invite_clients_on_create)
    end 

    #user.add_role :user
  end

  def importing_done
    Tenant::GeocodeSitesWorker.perform_async
  end

  def handle_model_errors(users)
    if users.present?
      self.error_messages = []

      errors = []
      
      users.each_with_index do |user, index|
        user.errors.full_messages.each do |message|

          errors = errors.push "Row #{index+2}: #{message}"

          # drill down to get site errors if there are any because by default,
          # rails only tells us that an association is invalid without drilling down into the
          # specific association related errors
          if user.sites.first.errors.count > 0
            user.sites.first.errors.full_messages.each do |site_message|
              errors.push "Row #{index+2}: Site #{site_message}"
            end
          end

          # the is invalid message is quite useless to us...
          # HACK :((
          # errors.delete_if{ |error| error.include? "is invalid" }

          # make sure every error message is uniq, another hack..
          errors = errors.uniq

          self.error_messages = errors
        end
      end
    end
  end
  
  def load_imported_user(row)
    client = Tenant::Client.new
    client.name = row["name"]
    client.email = row["email"]
    client.client_type = row["client_type"]
    client.phone_cell = row["phone_cell"]
    client.phone_landline = row["phone_landline"]
    client.phone_emergency = row["phone_emergency"]
    client.phone_emergency_2 = row["phone_emergency_2"]

    # create the billing address
    client.build_address(house_number: row["billing_house_number"].to_s, street_name: row["billing_street_name"].to_s, 
      line_2: row["billing_line_2"], city: row["billing_city"], province: row["billing_province_state"], 
      postal_code: row["billing_postal_zip"], country: row["billing_country"])

    site = Tenant::Site.new
    site.build_address(house_number: row["site_house_number"].to_s, street_name: row["site_street_name"].to_s, 
      line_2: row["site_line_2"], city: row["site_city"], province: row["site_province_state"], 
      postal_code: row["site_postal_zip"], country: row["site_country"])

    
    site.alarm_code = row["site_alarm_code"]
    site.alarm_safeword = row["site_alarm_safeword"]
    site.alarm_company = row["site_alarm_company"]
    site.emergency_number = row["site_emergency_number"]

    if row["site_zone"].present?
      zone = Tenant::Zone.find_or_initialize_by(name: row["site_zone"])

      site.zone = zone
    end
    
    client.sites << site

    client.roles << Tenant::Role.find_by(name: 'Client')

    client
  end



end