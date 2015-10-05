class Tenant::CReportsController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_owner, except: :show
  before_action :set_resource, only: [:edit, :update]
  before_action :set_resource_show, only: :show

  def index
    @resources = Tenant::Report.joins(qrid: [:site]).where.not(sent_at: nil).where('tenant_sites.owner_id = ?', @owner_id).order(sent_at: :desc)

    @site_id = params[:site_id]
    @resources = @resources.where('tenant_sites.id = ?', @site_id) if @site_id.present?

    @qrid_id = params[:qrid_id]
    @resources = @resources.where('tenant_qrids.id = ?', @qrid_id) if @qrid_id.present?

    @start_at = params[:start_at]
    @resources = @resources.where('submitted_at >= ?', @start_at.to_datetime) if @start_at.present?

    @end_at = params[:end_at]
    @resources = @resources.where('started_at < ?', @end_at.to_datetime) if @end_at.present?

    @status = params[:status]
    case @status
      when 'New'
        @resources = @resources.where(unread_by_client: true)
      when 'Flagged'
        @resources = @resources.where(flagged: true)
      when 'Closed'
        @resources = @resources.where('replied_at IS NOT NULL')
    end
  end

  def show
    @resource.update_columns(unread_by_client: false) if @resource.unread_by_client
    @resource.update_columns(received_at: Time.now) unless @resource.received_at
  end

  private

  def set_owner
    @owner_id = current_user.try(:id)
  end

  def set_resource
    @resource = Tenant::Report.joins(qrid: [:site]).where('tenant_sites.owner_id = ?', @owner_id).readonly(false).find(params[:id])
  end

  def set_resource_show
    @resource = Tenant::Report.joins(qrid: [:site]).readonly(false).find(params[:id])
  end
end
