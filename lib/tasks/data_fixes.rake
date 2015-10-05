namespace :data_fixes do

  desc "Fix QRID-835"
  task qrid_835: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        
        Apartment::Tenant.switch "tenant#{tenant.id}"

        root_task = Tenant::Task.find_by(origin_id: nil, qrid_id: nil, name: 'Post Residential Cleaning check list')

        unless root_task.nil?
          Tenant::Task.where(parent_id: root_task.id).each do |new_root|
            new_root.update(parent_id: nil)
          end

          root_task.destroy
        end

        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Reset notes counts for tenant reports to allow easier sorting"
  task reset_report_notes_count: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        
        Apartment::Tenant.switch "tenant#{tenant.id}"

        if tenant and tenant.timezone
          Time.use_zone(tenant.timezone) { 
            Tenant::Report.all.order(submitted_at: :asc).each do |report|
              report.set_reporter_time_data
            end
          }
        else
          raise 'No default timezone defined.'
        end
        # Tenant::ReportNote.all.each do |note|
        #   note.save!
        # end


        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Add a recurring_until_at field to all assignment overrides"
  task set_overrides_recurring_until_at: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        
        Apartment::Tenant.switch "tenant#{tenant.id}"

        Tenant::Assignment.all.each do |assignment|
          assignment.assignment_overrides.each do |override|
            override.recurring_until_at = assignment.recurring_until_at
            assignment.assignment_overrides << override

            if !assignment.save
              puts assignment.errors.full_messages.inspect
            end
          end
        end


        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Add a recurring_until_at field to all assignment overrides"
  task set_overrides_recurring_until_at: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        
        Apartment::Tenant.switch "tenant#{tenant.id}"

        Tenant::Assignment.all.each do |assignment|
          assignment.assignment_overrides.each do |override|
            override.recurring_until_at = assignment.recurring_until_at
            assignment.assignment_overrides << override

            if !assignment.save
              puts assignment.errors.full_messages.inspect
            end
          end
        end


        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Hack of a fix for a statable race condition bugs"
  task fix_statable_issues: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        
        Apartment::Tenant.switch "tenant#{tenant.id}"

        super_user = Tenant::Staff.find_by(super_user: true)

        Tenant::Site.all.each do |resource|
          item = Tenant::Staff.find_by(id: resource.try(:updated_tenant_staff_id))

          if item.nil?
            resource.updated_tenant_staff_id = super_user.id
            resource.save
          end

          item = Tenant::Staff.find_by(id: resource.try(:created_tenant_staff_id))

          if item.nil?
            resource.created_tenant_staff_id = super_user.id
            resource.save
          end
        end

        Tenant::Qrid.all.each do |resource|
          item = Tenant::Staff.find_by(id: resource.try(:updated_tenant_staff_id))

          if item.nil?
            resource.updated_tenant_staff_id = super_user.id
            resource.save
          end

          item = Tenant::Staff.find_by(id: resource.try(:created_tenant_staff_id))

          if item.nil?
            resource.created_tenant_staff_id = super_user.id
            resource.save
          end
        end


        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Hack of a fix affiliate id sequence after task transfer"
  task fix_affiliate_sequence: :environment do
    Admin::Tenant.where.not(parent_id: nil).where(affiliate_status: 'APPROVED').each do |tenant|
      begin

        Apartment::Tenant.switch "tenant#{tenant.id}"
        if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
          ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::Task.table_name)
          ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::Permatask.table_name)
          ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::WorkType.table_name)
        end
        Apartment::Tenant.switch

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end
end
