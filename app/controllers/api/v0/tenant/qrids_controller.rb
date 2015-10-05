class Api::V0::Tenant::QridsController < Api::V0::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:show]

  after_filter :set_status_code, only: [:index]

  def index
    page = params[:page].present? ? params[:page].to_i : 1
    page = 1 if page == 0

     # a constant describing how many tasks can the app load per page happily
     # right now it means that an account with 800 active tasks and an average of
     # 80 tasks per qrid can load 10 qrids per page
     # This maps to severn1's data characteristics
    tasks_per_page_constant = 800 

    num_per_page = 10
    avg_num_active_tasks = Tenant::Task.where(active: true, checked: true).where.not(qrid_id: nil).count / Tenant::Qrid.count

    num_per_page = (tasks_per_page_constant.to_f / avg_num_active_tasks).floor

    num_per_page = 1 if num_per_page == 0

    @resources = Tenant::Qrid.page(page).per_page(num_per_page).order(updated_at: :desc)
  end

  def show
    @resource.permatask_ids=Tenant::Permatask.roots.collect{|root| root.id}.select{|pt| @resource.permatask_ids.include?(pt)}
  end

  private
    def set_resource
      @resource = Tenant::Qrid.find(params[:id])
    end

    def set_status_code
      if @resources.size === 0
        self.status = 204
      end
    end

end