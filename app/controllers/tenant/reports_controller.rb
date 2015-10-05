class Tenant::ReportsController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:show, :edit, :update]

  def index
    #Tenant::Report.includes(:reporter, qrid: [{ site: :owner }, :work_type])
    @resources = Tenant::Report.joins(qrid: [:site]).where.not(submitted_at: nil).includes(:reporter, qrid: [{ site: :owner }, :work_type])#.order(submitted_at: :desc)

    @reporter_id ||= params[:reporter_id]
    @resources = @resources.where(reporter_id: @reporter_id) if @reporter_id.present?

    @work_type_id = params[:work_type_id]
    @resources = @resources.where('tenant_qrids.work_type_id = ?', @work_type_id) if @work_type_id.present?

    @zone_id = params[:zone_id]
    @resources = @resources.where('tenant_sites.zone_id = ?', @zone_id) if @zone_id.present?

    @owner_id = params[:owner_id]
    @resources = @resources.where('tenant_sites.owner_id = ?', @owner_id) if @owner_id.present?

    @site_id = params[:site_id]
    @resources = @resources.where('tenant_sites.id = ?', @site_id) if @site_id.present?

    @qrid_id = params[:qrid_id]
    @resources = @resources.where(qrid_id: @qrid_id) if @qrid_id.present?

    @start_at = params[:start_at]
    @resources = @resources.where('submitted_at >= ?', @start_at.to_datetime) if @start_at.present?

    @end_at = params[:end_at]
    @resources = @resources.where('started_at < ?', @end_at.to_datetime) if @end_at.present?

    respond_to do |format|
      format.html { @resources = @resources.order(submitted_at: :desc) }
      format.json { render json: Tenant::ReportsDatatable.new(view_context, @resources) }
    end    
  end

  def show
    @resource.update_columns(unread_by_manager: false) if @resource.unread_by_manager
  end

  def time
    from  = Time.at(params[:start].to_i)
    till  = Time.at(params[:end].to_i)

    @resources = Tenant::Report.where.not(submitted_at: nil).where(started_at: from..till)
  end

  private

  def set_resource
    @resource = (@reporter_id ? Tenant::Report.where(reporter_id: @reporter_id) : Tenant::Report).find(params[:id])
  end
end
