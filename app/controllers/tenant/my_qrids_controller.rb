class Tenant::MyQridsController < Tenant::QridsController
  include Uploadable

  prepend_before_action :set_work_type_id
  before_action :set_resource
  before_action :getAssignment

  def start
    if request.post?
      if @resource.site.nearby?(params[:latitude], params[:longitude], params[:accuracy])
        @resource.permatask_ids=Tenant::Permatask.roots.uniq.collect{|root| root.id}.select{|pt| @resource.permatask_ids.include?(pt)}
        if params[:permatask].nil?
          # Show first page
          @select_permatask = true
          # Finding reporter's assignment
        elsif !@resource.permatasks.empty? && params[:permatask].to_i > 0
          # Create new assignment and start permatask report
          assignment = Tenant::Assignment.create(
              start_at:     Time.at(params[:started_at_i].to_i),
              end_at:       Time.now + 1.hour,
              assignee_id:  current_user.id,
              qrid_id:      @resource.id,
              permatask:    true
          )
          @report_id = assignment.start_report(Time.at(params[:started_at_i].to_i))

          @permatask = params[:permatask].to_i
          flash.now[:notice] = 'Your location is confirmed.'
        else
          # Finding reporter's assignment
          options = {
              assignee_id: current_user.id,
              qrid_id: @resource.id,
              status: ['Open', 'In Progress']
          }
          assignment = Tenant::Assignment.list(Time.now - 1.day, Time.now + 1.day, options).first

          if assignment
            # Start common task report
            @report_id = assignment.start_report(Time.at(params[:started_at_i].to_i))

            @permatask = 0
            @assignment=assignment
            flash.now[:notice] = 'Your location is confirmed.'
          elsif current_user.settings.allow_reporting_with_no_assignment

            # create a new assignment for this user on the fly
            
            assignment = Tenant::Assignment.create(
                start_at:     Time.at(params[:started_at_i].to_i),
                end_at:       Time.now + 1.hour,
                assignee_id:  current_user.id,
                qrid_id:      @resource.id
            )
            @report_id = assignment.start_report(Time.at(params[:started_at_i].to_i))
            @permatask = 0
            flash.now[:notice] = 'Your location is confirmed.'
          else
            flash.now[:alert] = 'Sorry, you have not been assigned this QRID'
          end
        end
      else
        flash.now[:alert] = 'You\'re too far from the site.'
      end
    end

    setup_s3_upload
  end

  private

  def set_resource
    @resource = Tenant::Qrid.find(params[:id])
  end
  def set_work_type_id; @work_type_id = current_user.try(:staff_work_type_ids) end
  def getAssignment
    options = {
        assignee_id: current_user.id,
        qrid_id: @resource.id,
        status: ['Open', 'In Progress']
    }
    @assignment=Tenant::Assignment.list(Time.now - 1.day, Time.now + 1.day, options).first

  end
end