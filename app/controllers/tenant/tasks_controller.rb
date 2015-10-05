class Tenant::TasksController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:edit, :update, :rebuild, :destroy, :create, :new, :show, :trial]
  
  def index
    @work_type_id = params[:work_type_id]
    @client_type  = params[:client_type]
    @resources = Tenant::Task.join_recursive { |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)
    }
                     .where(qrid_id: nil)
                     .where(work_type_id: @work_type_id)
                     .where(client_type: @client_type)
  end

  def new(type = nil)
    @resource = Tenant::Task.new(active: true)
    if params[:parent_id].present?
      @resource.parent_id     = params[:parent_id]
      parent = Tenant::Task.find(@resource.parent_id)
      @resource.work_type_id  = parent.work_type_id
      @resource.client_type   = parent.client_type
      @resource.qrid_id       = parent.qrid_id
    else
      @resource.work_type_id  = params[:work_type_id]   if params[:work_type_id].present?
      @resource.client_type   = params[:client_type]    if params[:client_type].present?
      @resource.qrid_id       = params[:qrid_id]        if params[:qrid_id].present?
    end
  end

  def create
    @resource = Tenant::Task.new(resource_params)
    @resource.checked = true if resource_params[:qrid_id].present?
    
    if @resource.save
      if @resource.parent_id.to_i > 0
        @resource.move_to_child_of Tenant::Task.find(@resource.parent_id)
        parent = Tenant::Task.find(@resource.parent_id)
		    if parent && parent.respond_to?(:origin_id) && parent.origin_id
            @resource.origin_id = @resource.id
        end		
      end
          
      sorted_siblings = @resource.siblings.sort() { |a,b| a.position <=> b.position }
      case @resource.task_type
        when 'Question','Group'
          rightmost = sorted_siblings.last
          @resource.move_to_right_of rightmost if rightmost
        when 'Photo','Comment','Instructions'
          leftmost = sorted_siblings.first
          @resource.move_to_left_of leftmost if leftmost
      end

      respond_smart_with @resource, {}, (@resource.qrid_id ?
        edit_tenant_qrid_url(@resource.qrid_id) :
        tenant_tasks_url(work_type_id: @resource.work_type_id, client_type: @resource.client_type)
      )
    else
      render inline: @resource.errors.inspect      
    end
  rescue => ex
    flash.now[:alert] = 'Regrettably, an error occured while creating this task.'
  end

  def update
    respond_smart_with @resource, {}, (@resource.qrid_id ? edit_tenant_qrid_url(@resource.qrid_id) : tenant_tasks_url(work_type_id: @resource.work_type_id, client_type: @resource.client_type)) if @resource.update(resource_params)    
  end

  def rebuild
    parent_id = params[:parent_id].to_i
    prev_id   = params[:prev_id].to_i
    next_id   = params[:next_id].to_i

    if parent_id == 0 && prev_id == 0 && next_id == 0
      render nothing: true, status: :no_content
    else
      if @resource.can_be_nested_in?(parent_id)
        if prev_id == 0 && next_id == 0
          @resource.move_to_child_of Tenant::Task.find(parent_id)
        elsif prev_id != 0
          @resource.move_to_right_of Tenant::Task.find(prev_id)
        elsif next_id != 0
          @resource.move_to_left_of Tenant::Task.find(next_id)
        end
        render nothing: true, status: :ok

      else
        flash[:alert] = "This task cannot be moved here"
        render nothing: true, status: :method_not_allowed        
      end
    end
  end

  def destroy
    begin
      if @resource.origin_id.nil? || @resource.origin_id == 0
        @resource.destroy
      else
        Tenant::Task.each_with_level(@resource.self_and_descendants) do |item|
          item.update(checked: false)
        end
      end
      
      respond_smart_with @resource, {}, (@resource.qrid_id ?
        edit_tenant_qrid_url(@resource.qrid_id) :
        tenant_tasks_url(work_type_id: @resource.work_type_id, client_type: @resource.client_type)
      )
    end
  end

  private

  def set_resource
    if params[:id].present?
      @resource = Tenant::Task.find(params[:id])
    end
  end

  def resource_params
    params.require(:tenant_task).permit(:parent_id, :name, :task_type, :work_type_id, :client_type, :qrid_id, :active,:for_affiliates)
  end
end
