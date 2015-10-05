class Api::V0::Tenant::AssignmentsController < Api::V0::BaseController
  include Tenant::Assignments

  before_action :set_resource, only: [:show, :edit, :update, :reschedule, :destroy]
  after_filter :set_status_code, only: [:index]

  def index
    process_index_action
  end

  def show
  end

  def update
    @resource.update(resource_params)
    render :show
  end 

  # def new
  #   @resource = Tenant::Assignment.new
  #   @resource.qrid_id = params[:qrid_id].to_i if params[:qrid_id].present?
  #   @resource.assignee_id = params[:assignee_id].to_i if params[:assignee_id].present?
  #   @resource.start_at = params[:start_at] if params[:start_at].present?
  #   @resource.end_at = params[:end_at] if params[:end_at].present?
  # end

  # def edit
  #   if params[:instance_start].present? and params[:instance_end].present?
  #     # this is a recurring event for which overrides must exist in which case
  #     # we should just return the already properly calculated start and end dates
  #     # returned during the index action

  #     @resource.comment = params[:comment] if params[:comment].present?
  #     @resource.assignee_id = params[:assignee_id] if params[:assignee_id].present?
  #     @resource.comment = params[:comment] if params[:comment].present?

  #     # the event instance was just clicked

  #     @resource.start_at = DateTime.parse(params[:instance_start]).to_time
  #     @resource.end_at = DateTime.parse(params[:instance_end]).to_time

  #     @resource.qrid_id = params[:qrid_id] if params[:qrid_id].present?
  #     @resource.assignee_id = params[:assignee_id] if params[:assignee_id].present?
      
  #     #@resource.overrided_start_at  = DateTime.parse(params[:instance_start]).to_time

  #     if params[:day_delta].present? && params[:minute_delta].present?
  #       # the event was dragged elsewhere and dropped here

  #       # the * -1 is to allow us to go back to what the date/time was before the drag n drop
  #       d = params[:day_delta].to_i * -1 
  #       m = params[:minute_delta].to_i * -1
        
  #       @resource.overrided_start_at  = DateTime.parse(params[:instance_start]).to_time.advance(days: d, minutes: m)
  #     else
  #       @resource.overrided_start_at  = DateTime.parse(params[:instance_start]).to_time
  #     end
  #   else
  #     # not a recurring event, everything is still nice and simple

  #     if params[:day_delta].present? && params[:minute_delta].present?
  #       # the event was dragged elsewhere and dropped here

  #       d = params[:day_delta].to_i
  #       m = params[:minute_delta].to_i
  #       @resource.start_at  = @resource.start_at.advance(days: d, minutes: m)
  #       @resource.end_at    = @resource.end_at.advance(days: d, minutes: m)
  #     end
  #   end
  # end

  # def create
  #   @resource = Tenant::Assignment.new(resource_params)
  #   # QRID-920 Fixed
  #   @resource.save
  #   respond_smart_with @resource
  # end

  # def update
  #   @resource.update(resource_params)
  #   respond_smart_with @resource
  # end

  # def reschedule
  #   if @resource.status != 'Open'
  #     flash[:alert] = 'Non-Open assignment cannot be rescheduled'
  #     render nothing: true, status: :method_not_allowed
  #     return
  #   end
  #   d = params[:day_delta].to_i
  #   m = params[:minute_delta].to_i
  #   case params[:cal_action]
  #     when 'move'
  #       @resource.start_at  = @resource.start_at.advance(days: d, minutes: m)
  #       @resource.end_at    = @resource.end_at.advance(days: d, minutes: m)
  #     when 'resize'
  #       @resource.end_at    = @resource.end_at.advance(days: d, minutes: m)
  #   end
  #   flash.now[:notice] = 'Assignment has been rescheduled.'  if @resource.save
  # end

  # def destroy
  #   if @resource.status == 'Done'
  #     respond_smart_with @resource, alert: 'You cannot delete a completed assignment'
  #   else
  #     begin
  #       @resource.destroy
  #       respond_smart_with @resource
  #     rescue Exception => e
  #       respond_smart_with @resource, alert: e.message
  #     end
  #   end
  # end

  private

  def set_status_code
    if @resources.size === 0
      self.status = 204
    end
  end
end
