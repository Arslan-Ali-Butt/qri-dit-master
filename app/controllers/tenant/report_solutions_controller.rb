class Tenant::ReportSolutionsController < Tenant::BaseController
  include Crudable

  authorize_resource class: false
  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  def index
    @resources = @parent.solutions

    @report_task_id = params[:report_task_id]
    @resources = @resources.where(report_task_id: @report_task_id) if @report_task_id.present?
  end

  def new
    @resource = @parent.solutions.new
    @resource.report_task_id = params[:report_task_id] if params[:report_task_id].present?
  end

  def create
    @resource = @parent.solutions.new(resource_params)
    @resource.save
    respond_smart_with @resource
  end

  def update
    if params[:accept]
      @resource.update(accepted: true, declined: false)
    elsif params[:decline]
      @resource.update(accepted: false, declined: true)
    else
      @resource.update(resource_params)
    end
    respond_smart_with @resource
  end

  private

  def set_parent
    @parent = Tenant::Report.find(params[:report_id])
  end

  def set_resource
    @resource = Tenant::ReportSolution.find(params[:id])
  end

  def resource_params
    params.require(:tenant_report_solution).permit(:report_task_id, :description, :accepted)
  end
end
