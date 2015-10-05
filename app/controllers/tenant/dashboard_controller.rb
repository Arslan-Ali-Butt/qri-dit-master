class Tenant::DashboardController < Tenant::BaseController
  def index
    @show_getting_started_popup = true
    if current_user.settings && current_user.settings.getting_started_popup_shown
      @show_getting_started_popup = false
    end

    if @show_getting_started_popup && current_user.super_user
      Tenant::Mailer.welcome_message(current_user).deliver
    end

    if current_user.role?(:admin) || current_user.role?(:manager)
      @reports = Tenant::Report.includes(:reporter).where.not(submitted_at: nil).order(submitted_at: :desc).limit(5)
      @assignments = Tenant::Assignment.list(Time.now - 1.day, Time.now + 1.day, {status: ['Open', 'In Progress']})
      render 'manager'

    elsif current_user.role?(:reporter)
      @reports = Tenant::Report.where(reporter_id: current_user.id).where.not(submitted_at: nil).order(submitted_at: :desc).limit(5)
      @assignments = Tenant::Assignment.list(Time.now - 1.day, Time.now + 1.day, {assignee_id: current_user.id, status: ['Open', 'In Progress']})
      render 'reporter'

    else
      @reports = Tenant::Report.joins(qrid: [:site]).where.not(sent_at: nil).where('tenant_sites.owner_id = ?', current_user.id).order(submitted_at: :desc).limit(5)
      render 'client'
    end
  end

  def weather
    if params[:latitude].present? && params[:longitude].present? && !ENV['WEATHER_API_KEY'].nil?
      @latitude   = params[:latitude].to_f.round(4)
      @longitude  = params[:longitude].to_f.round(4)

      http = Net::HTTP.new('api.forecast.io', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.start do |session|
        req = Net::HTTP::Get.new("/forecast/#{ENV['WEATHER_API_KEY']}/#{@latitude},#{@longitude}#{Admin::Tenant.cached_find_by_host(request.host).metric ? "?units=ca" : ""}", {'User-Agent' => 'qridithomewatch.com using Ruby on Rails 4.0.2'})
        response = session.request(req)
        @weather = MultiJson.load(response.body)
      end
    end
    render layout: false
  end

  def getting_started
    if current_user.settings
      unless current_user.settings.getting_started_popup_shown
        current_user.settings.update_columns(getting_started_popup_shown: true)
      end
    else
      current_user.create_settings!(getting_started_popup_shown: true)
    end
    render layout: false
  end
end
