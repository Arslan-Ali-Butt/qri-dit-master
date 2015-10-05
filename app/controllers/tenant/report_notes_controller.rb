class Tenant::ReportNotesController < Tenant::BaseController
  include Crudable

  authorize_resource class: false
  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete]

  def index
    redirect_to edit_tenant_report_path(id: params[:report_id])
  end

  def new
    @resource = @parent.notes.new
  end

  def create
    @resource = @parent.notes.new(resource_params)
    if @resource.save
      notice = 'Note has been created.'
      if params[:send_to].present?
        case params[:send_to]
          when 'c'
            Tenant::Mailer.c_report_notification(@resource).deliver
            if @parent.sent_at.nil?
              notice = 'Report has been submitted to client.'
            else
              notice = 'Message sent successfully'

              # now mark the last unread client comment as read if one exists
              unless @parent.client_notes.where(unread_by_manager: true).empty?
                @parent.client_notes.where(unread_by_manager: true).update_all(unread_by_manager: false)
              end
            end
            @parent.update_columns(unread_by_client: true, sent_at: Time.now)
          when 'm'
            tenant = Admin::Tenant.cached_find_by_host(request.host)

            Tenant::Mailer.reply_notification(@resource, tenant).deliver
            if @parent.replied_at.nil?
              notice = 'Confirmation has been submitted to manager.'
            else
              notice = 'message sent succesfully'
            end
            @parent.update_columns(replied_at: Time.now)
        end
      end
      respond_smart_with @resource, notice: notice
    else
      respond_smart_with @resource
    end
  end

  def update
    @resource.update(resource_params)

    if params[:update_all_notes]
      current_note_created_at = @resource.created_at.getutc.strftime "%Y-%m-%d %H:%M:%S"
      Tenant::ReportNote.where(unread_by_manager: true).where(report_id: @resource.report_id)
        .where("#{Tenant::ReportNote.table_name}.created_at <= '#{current_note_created_at}'")
        .each do |note|
          note.update(unread_by_manager: false)
        end
    end
    respond_smart_with @resource
  end

  private

  def set_parent
    @parent = Tenant::Report.find(params[:report_id])
  end

  def set_resource
    @resource = Tenant::ReportNote.find(params[:id])
  end

  def resource_params
    ret = params.require(:tenant_report_note).permit(:note, :unread_by_manager)
    ret[:author_id] = current_user.try(:id) if (!params[:is_author].present? or params[:is_author] == "true")
    ret
  end
end
