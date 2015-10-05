class Tenant::PermatasksController < Tenant::BaseController
  include Crudable

  authorize_resource class: false
  before_action :set_resource, only: [:edit, :update, :rebuild, :destroy, :show, :trial]

  def index
    @resources = Tenant::Permatask.join_recursive do |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)
      end
  end

  def new
    @resource = Tenant::Permatask.new(active: true)
    @resource.parent_id = params[:parent_id] if params[:parent_id].present?
  end

  def create
    @resource = Tenant::Permatask.new(resource_params)
    if @resource.save
      if @resource.parent_id.to_i > 0
        @resource.move_to_child_of Tenant::Permatask.find(@resource.parent_id)
      end

      if params[:on_top].present?
        leftmost = (@resource.siblings.sort() { |a,b| a.position <=> b.position }).first
        @resource.move_to_left_of leftmost if leftmost
      end
    end
    # respond_smart_with @resource
  end

  def update
    @resource.update(resource_params)
    respond_smart_with @resource
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
          @resource.move_to_child_of Tenant::Permatask.find(parent_id)
        elsif prev_id != 0
          @resource.move_to_right_of Tenant::Permatask.find(prev_id)
        elsif next_id != 0
          @resource.move_to_left_of Tenant::Permatask.find(next_id)
        end
        render nothing: true, status: :ok

      else
        flash[:alert] = "This permatask cannot be moved here"
        render nothing: true, status: :method_not_allowed
      end
    end
  end

  private

  def set_resource
    @resource = Tenant::Permatask.find(params[:id])
  end

  def resource_params
    params.require(:tenant_permatask).permit(:parent_id, :name, :task_type, :active,:for_affiliates)
  end
end
