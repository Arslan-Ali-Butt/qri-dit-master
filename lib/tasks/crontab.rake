namespace :crontab do

  desc "Daily task list"
  task :daily do
    Rake::Task['crontab:send_daily_assignment_notifications'].invoke
  end

  desc "Send daily notifications about upcoming assignments"
  task send_daily_assignment_notifications: :environment do
    Admin::Tenant.all.each do |tenant|
      begin
        assignment_notification_time = tenant.assignment_notification_time
        if (!assignment_notification_time.nil? and assignment_notification_time > 0)
          from = Time.now.beginning_of_day + (assignment_notification_time - 1).day
          till = Time.now.beginning_of_day + assignment_notification_time.day

          ActionMailer::Base.default_url_options = {host: tenant.host_url}

          Apartment::Tenant.switch "tenant#{tenant.id}"
          Tenant::Assignment.list(from, till, {status: 'Open'}).each do |assignment|
            Tenant::Mailer.assignment_notification(assignment).deliver
          end
          Apartment::Tenant.switch
        end

      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

end
