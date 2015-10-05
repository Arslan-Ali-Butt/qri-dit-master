class Api::V0::Tenant::ReportsController < Api::V0::BaseController
  include Tenant::Reports

  authorize_resource class: false
  
  def create
    #abort report_params.inspect

    if report_params[:assignment_id].present?
      assignment = Tenant::Assignment.find_by(id: report_params[:assignment_id])

      if assignment.nil?
        # assignment was cancelled before report was submitted

        assignment = Tenant::Assignment.create!(
            start_at:     Time.at(report_params[:started_at_i].to_i),
            end_at:       Time.now + 1.hour,
            assignee_id:  current_user.id,
            qrid_id:      report_params[:qrid_id]
        )
      end

    elsif report_params[:is_permatask_report].present? and report_params[:is_permatask_report] == true
      # Create new assignment and start permatask report

      assignment = Tenant::Assignment.create!(
          start_at:     Time.at(report_params[:started_at_i].to_i),
          end_at:       Time.now + 1.hour,
          assignee_id:  @current_user.id,
          qrid_id:      report_params[:qrid_id],
          permatask:    true
      )
    else
      if @current_user.settings.allow_reporting_with_no_assignment

        # create a new assignment for this user on the fly
        
        assignment = Tenant::Assignment.create!(
            start_at:     Time.at(report_params[:started_at_i].to_i),
            end_at:       Time.now + 1.hour,
            assignee_id:  current_user.id,
            qrid_id:      report_params[:qrid_id]
        )
      else
        # somehow, the user is trying to report on a qrid they are not allowed to

        response = { error: "Sorry, you have not been assigned this QRID and cannot complete a report on it" }

        render json: response, status: :forbidden 

        return 
      end
    end
    
    started_at = Time.at(report_params[:started_at_i].to_i)
    original_assignment = assignment.prepare_to_start_report(started_at)

    if original_assignment.report
      original_assignment.report.update(started_at: started_at)
    else
      original_assignment.create_report!(started_at: started_at)
    end
    @report_id = original_assignment.report.id

    @resource = Tenant::Report.where(reporter_id: @current_user.id).find(@report_id)

    @resource.submit(report_params)



    head status: :created
    # if Admin::Tenant.cached_find_by_host(request.host).allow_reporters_to_view_reports
    #   #location = tenant_my_reports_url
    #   location = tenant_root_url
    # else
    #   location = tenant_root_url
    # end
    # respond_smart_with @resource, {notice: 'Report has been submitted'}, location
  end

end