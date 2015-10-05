class Tenant::UsersController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:show, :edit, :update, :invite, :destroy, :delete, :restore]

  def index
    @role = params[:role]
    if @role.present?
      @resources = Tenant::User.by_role(@role)#.order(:name)
    else
      @resources = (role_name ? Tenant::User.by_role(role_name) : Tenant::Staff.by_role(['Reporter', 'Manager', 'Admin']))#.order(:name)
    end

    @staff_work_type_id = params[:staff_work_type_id]
    @resources = @resources.includes(:staff_work_types).where(tenant_work_types: {id: @staff_work_type_id}) if @staff_work_type_id.present?

    @staff_zone_id = params[:staff_zone_id]
    @resources = @resources.includes(:staff_zones).where(tenant_zones: {id: @staff_zone_id}) if @staff_zone_id.present?

    @status = params[:status] || ['Active', 'Suspended']

    # a hack for the way URI.js is handling our status array get parameter
    if params[:context] == 'datatables'
      @status = @status[0].split(',')
    end

    @resources = @resources.where(status: @status) if @status.present?

    @id = params[:id]
    @resources = @resources.where(id: @id) if @id.present?

    today = Date.today
    @reports_this_week = Tenant::Report.select('reporter_id AS id, SUM(EXTRACT(EPOCH FROM(submitted_at - started_at))) AS total_in_secs').where.not(submitted_at: nil).where('submitted_at >= ? AND submitted_at < ?', today.beginning_of_week, today.beginning_of_week + 7.days).group(:reporter_id)

    @worked_this_week = {}
    @resources.each do |user|
      report = @reports_this_week.detect { |r| r.id.to_i == user.id }
      @worked_this_week[user.id] = report ? report.total_in_secs.to_i : 0
    end

    @hours_this_week = params[:hours_this_week]
    if @hours_this_week.present?
      min_sec = Tenant::Staff::HOURS_THIS_WEEK[@hours_this_week.to_i][1]
      min_sec *= 3600 if min_sec
      max_sec = Tenant::Staff::HOURS_THIS_WEEK[@hours_this_week.to_i][2]
      max_sec *= 3600 if max_sec

      user_ids = []
      @worked_this_week.each do |id, secs|
        if (min_sec.nil? || secs >= min_sec) && (max_sec.nil? || secs < max_sec)
          user_ids << id
        end
      end
      @resources = @resources.where(id: user_ids)
    end
  end

  def new
    @resource = Tenant::User.new
    @resource.build_address(country: 'CA')
    @resource.build_settings()
  end

  def edit
    @resource.build_address(country: 'CA') unless @resource.address
    @resource.build_settings() unless @resource.settings
  end

  def create
    # User.invite! doesn't do honest validation (it saves user's roles even if user is invalid)
    # so we have a workaround here
    @resource = Tenant::User.new(resource_params)
    if @resource.valid?
      @resource = Tenant::User.invite!(resource_params, current_user)
    end
    respond_smart_with @resource, notice: "#{@resource.display_name} has been invited."
  end

  def update
    email_not_changed = (resource_params[:email] == @resource.email)
    if @resource.invitation_accepted? || email_not_changed
      if @resource.update(resource_params)
        notice = email_not_changed ?
            "#{@resource.display_name} has been updated." :
            "#{@resource.display_name} has been updated, but we need to verify their new email address."
      end
    else
      @resource.skip_reconfirmation!
      if @resource.update(resource_params) && @resource.invite!(current_user)
        notice = "#{@resource.display_name} has been re-invited."
      end
    end
    respond_smart_with(@resource, notice ? {notice: notice} : {})
  end

  def invite
    if @resource.invite!(current_user)
      redirect_to url_for(controller: controller_name, action: :index),
                  notice: "#{@resource.display_name} has been re-invited."
    else
      render action: :edit
    end
  end

  def destroy
    case params[:opt]
      when 'destroy'
        begin
          reassign_to = params[:reassign_to].to_i
          if reassign_to > 0
            Tenant::Assignment.where(assignee_id: @resource.id).update_all(assignee_id: reassign_to)
          end
          @resource.destroy
          respond_smart_with @resource
        rescue Exception => e
          respond_smart_with @resource, alert: e.message
        end
      when 'disable'
        @resource.update(status: 'Deleted')
        respond_smart_with @resource, notice: "#{@resource.display_name} has been disabled."
    end
  end

  def restore
    @resource.update(status: 'Active')
    respond_smart_with @resource, notice: "#{@resource.display_name} has been restored."
  end

  private

  def set_resource
    @resource = (role_name ? Tenant::User.by_role(role_name) : Tenant::User).find(params[:id])
  end

  def resource_params
    ret = params.require(:tenant_user).permit(:name, :email, :phone_cell, :phone_landline, :phone_emergency, :phone_emergency_2, :client_type, :staff_daily_hours, :notes, :suspended_status, address_attributes: [:id, :house_number, :street_name, :line_2, :city, :province, :postal_code, :country], settings_attributes: [:id, :disable_assignment_notifications, :disable_report_notifications, :allow_reporting_with_no_assignment], staff_zone_ids: [], staff_work_type_ids: [], role_ids: [])
    ret[:role_ids] = [Tenant::Role.find_by!(name: role_name).id] if role_name
    ret
  end

  def role_name; nil end
end
