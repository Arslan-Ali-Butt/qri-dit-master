require 'rqrcode'

class Tenant::QridsController < Tenant::BaseController
  authorize_resource class: false
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :delete, :qrcard, :qrcode, :trial, :start, :nominate, :populate, :customize, :augment, :rehash, :duplicate]
  
  def index
    @resources = Tenant::Qrid.joins(site: [:owner, :address]).includes(:work_type, site: [:owner, :address])

    @work_type_id ||= params[:work_type_id]
    @resources = @resources.where(work_type_id: @work_type_id) if @work_type_id.present?

    @client_type = params[:client_type]
    @resources = @resources.where('tenant_users.client_type = ?', @client_type) if @client_type.present?

    @owner_id = params[:owner_id]
    @resources = @resources.where('tenant_sites.owner_id = ?', @owner_id) if @owner_id.present?

    @city = params[:city]
    @resources = @resources.where('tenant_addresses.city = ?', @city) if @city.present?

    @zone_id = params[:zone_id]
    @resources = @resources.where('tenant_sites.zone_id = ?', @zone_id) if @zone_id.present?

    @site_id = params[:site_id]
    @resources = @resources.where('tenant_sites.id = ?', @site_id) if @site_id.present?

    @status = params[:status] || 'Active'
    @resources = @resources.where(status: @status) if @status.present?

    @id = params[:id]
    @resources = @resources.where(id: @id) if @id.present?

    respond_to do |format|
      format.html
      format.json { 
        if params[:context] == 'datatables'
          render json: Tenant::QridsDatatable.new(view_context, @resources) 
        end
      }
    end    
  end
  
  def new
    @resource = Tenant::Qrid.new
    @resource.site_id = params[:site_id].to_i if params[:site_id]
  end
  
  def create
    @resource = Tenant::Qrid.new(resource_params)
    if @resource.save

      if params[:end_of_wizard_return_path].present?
        # we only want to invoke the return_path at the end of the creation process
        session[:return_path] = params[:end_of_wizard_return_path]
      end


      # the QRID has been created, inform Chargify...
      Tenant::UpdateQridsOnPlanWorker.perform_async
      # chargify notification completed

      respond_smart_with @resource, {}, nominate_tenant_qrid_path(@resource)
    else
      respond_smart_with @resource
    end
  end
  
  def populate
    begin
      # set active and checked flag on all nominated tasks

      items = nominated_tasks

      if items
        items.each do |item|
          Tenant::Task.update item, :checked => true
        end
      end
    rescue => ex
      # do nothing
    ensure  
      redirect_to customize_tenant_qrid_path @resource
    end
  end

  def rehash
    begin
      items = augmented_tasks

      if items
        items.each do |item|
          Tenant::Task.update item, :checked => true
        end
      end
    rescue => ex
      # do nothing
    ensure    
      redirect_to edit_tenant_qrid_path @resource
    end
  end


  def update
    # render inline: resource_params.inspect
    
    update_params = {}
    update_params.merge(resource_params)
    update_params.merge(permatask_params)
    
    @resource.update(resource_params)
    # render inline: @resource.errors.inspect
    respond_smart_with @resource, {}, edit_tenant_qrid_url(@resource)
  end

  def destroy
    case params[:opt]
      when 'destroy'
        begin
          @resource.destroy

          # the QRID has been deleted, inform Chargify...
          Tenant::UpdateQridsOnPlanWorker.perform_async

          respond_smart_with @resource
        rescue Exception => e
          respond_smart_with @resource, alert: e.message
        end
      when 'disable'
        @resource.update(status: 'Deleted')

        # the QRID has been soft deleted, inform Chargify...
        Tenant::UpdateQridsOnPlanWorker.perform_async

        respond_smart_with @resource, notice: "#{@resource.display_name} has been disabled."
    end
  end

  def qrcard
    @qr = RQRCode::QRCode.new(start_tenant_my_qrid_url(@resource), size: 4, level: :l)
    render layout: false
  end

  def qrcode
    @qr = RQRCode::QRCode.new(start_tenant_my_qrid_url(@resource), size: 4, level: :l)
    respond_to do |format|
      format.svg do
        render text: @qr.as_svg.html_safe, content_type: 'image/svg+xml'
      end
      format.png do
        render text: @qr.as_png(border_modules: 0), content_type: 'image/png'
      end
    end
  end

  def augment


    unmodified_template_tasks = Tenant::Task
                                    .joins("INNER JOIN #{Tenant::Task.table_name} AS tenant_tasks_2 ON tenant_tasks_2.id = #{Tenant::Task.table_name}.origin_id AND tenant_tasks_2.name = #{Tenant::Task.table_name}.name")
                                    .where(qrid_id: @resource.id).where(active: true).where(checked: true).readonly(false)

    modified_template_tasks = Tenant::Task
                                  .joins("INNER JOIN #{Tenant::Task.table_name} AS tenant_tasks_2 ON tenant_tasks_2.id = #{Tenant::Task.table_name}.origin_id AND tenant_tasks_2.name != #{Tenant::Task.table_name}.name")
                                  .where(qrid_id: @resource.id).where(active: true).where(checked: true)

    num_modified_template_tasks = modified_template_tasks.count

    if num_modified_template_tasks == 0
      # the user has not modified any of the included template checklists so we are good :)
    else
      # handle the root tasks that contain modifications
      @modified_checklists = []
      Tenant::Task.roots.each do |root|
        modified_descendants = modified_template_tasks.where(origin_id: root.self_and_descendants.pluck(:id))

        if modified_descendants.count > 0
          # this particular checklist was modified

          unmodified_descendants = unmodified_template_tasks.where(origin_id: root.self_and_descendants.pluck(:id))

          if unmodified_descendants.count < root.self_and_descendants.count
            # the QRID does not currently have an unmodified version of this template checklist available to include
            # so add one
            @resource.duplicate_tasks(root.self_and_descendants)
          end

          @modified_checklists.push root.id
        end
      end
    end
    @tasks = Tenant::Task.join_recursive { |query|
      query
          .start_with(parent_id: nil)
          .connect_by(id: :parent_id)
          .order_siblings(position: :asc)
      }          .where(qrid_id: @resource.id)
                 .where(origin_id: Tenant::Task
                                       .where(qrid_id: nil)
                                       .pluck(:id)
                 )
  end

  def duplicate
    if request.post?
      @resource = Tenant::Qrid.new(resource_params)
      @dup_resource = Tenant::Qrid.find(params[:id])
      
      @resource.permatask_ids = @dup_resource.permatask_ids.dup
      @resource.assignments = @dup_resource.assignments.dup
      # QHWS-7
      # @resource.reports = @dup_resource.reports.dup

      if @resource.save
        @resource.duplicate_tasks(@dup_resource.tasks.join_recursive do |query|
                                    query
                                        .start_with(parent_id: nil)
                                        .connect_by(id: :parent_id)
                                        .order_siblings(position: :asc)
                                  end
        )
        respond_smart_with @resource, {}, edit_tenant_qrid_url(@resource)
      else
        render
      end
    else
      @dup_resource = Tenant::Qrid.find(params[:id])
      @resource = @dup_resource.dup

      @resource.site = @dup_resource.site.dup
      @resource.permatask_ids = @dup_resource.permatask_ids.dup
      @resource.tasks = @dup_resource.tasks.dup
      @resource.assignments = @dup_resource.assignments.dup
      # QHWS-7
      # @resource.reports = @dup_resource.reports.dup

      @resource.name = nil
      @resource.estimated_duration = nil
    end
  end

  def trial
    if params[:return_path].present?
      # we had a return_path set at the beginning of the creation process so redirect to it
      # now that we are done
      # session[:return_path] = nil # reset this session variable
      # redirect_to params[:return_path]
    end
  end
  
  def print
    render 'print', layout: false
  end

  private

  def set_resource
    @resource = Tenant::Qrid.find(params[:id])
  end

  def resource_params
    ret = params.require(:tenant_qrid).tap do |whitelisted|
      whitelisted[:work_type_id] = params[:tenant_qrid][:work_type_id]
      whitelisted[:site_id] = params[:tenant_qrid][:site_id]
      whitelisted[:estimated_duration] = params[:tenant_qrid][:estimated_duration]
      whitelisted[:alarm_code] = params[:tenant_qrid][:alarm_code]
      whitelisted[:alarm_safeword] = params[:tenant_qrid][:alarm_safeword]
      whitelisted[:alarm_company] = params[:tenant_qrid][:alarm_company]
      whitelisted[:key_box_code] = params[:tenant_qrid][:key_box_code]
      whitelisted[:instruction]=params[:tenant_qrid][:instruction]
    end
    ret.permit!
  end
  
  def permatask_params
    ret = params.require(:tenant_qrid).tap do |whitelisted|
      if !params[:tenant_qrid][:permatask_ids].nil? && params[:tenant_qrid][:permatask_ids].count > 0
        whitelisted[:permatask_ids] = params[:tenant_qrid][:permatask_ids] 
      else
        whitelisted[:permatask_ids] = []
      end
    end
    ret.permit!
  end

  def nominated_tasks
    params.require(:tenant_qrid).require(:default_task_ids)
  end

  def augmented_tasks
    params.require(:tenant_qrid).require(:default_task_ids)
  end
end
