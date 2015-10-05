class Tenant::MyReportsController < Tenant::ReportsController
  include Tenant::Reports

  prepend_before_action :check_access
  prepend_before_action :set_reporter

  def submit
    @resource = Tenant::Report.where(reporter_id: @reporter_id).find(params[:id])

    @resource.submit(report_params)
    if Admin::Tenant.cached_find_by_host(request.host).allow_reporters_to_view_reports
      #location = tenant_my_reports_url
      location = tenant_root_url
    else
      location = tenant_root_url
    end
    respond_smart_with @resource, {notice: 'Report has been submitted'}, location
  end

  private

  def check_access
    unless Admin::Tenant.cached_find_by_host(request.host).allow_reporters_to_view_reports || action_name == 'submit' || current_user.role?(:manager) || current_user.role?(:admin)
      raise CanCan::AccessDenied.new
    end
  end

  def set_reporter; @reporter_id = current_user.try(:id) end
end
