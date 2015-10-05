module Respondable
  private

  def respond_smart_with(resource, msg = {}, location = nil)    
    if resource.respond_to?(:errors) && !resource.errors.empty?
      case action_name.to_sym
        when :create
          render action: :new
        when :update
          render action: :edit
        when :destroy
          render action: :delete
        else
          render action: :index
      end
    else
      display_name = resource.respond_to?(:display_name) ? resource.display_name : 'Resource'
      case action_name.to_sym
        when :create
          notice = "#{display_name} has been created."
        when :update
          notice = "#{display_name} has been updated."
        when :destroy
          notice = "#{display_name} has been deleted."
      end
      respond_to do |format|
        format.html do
          if !params[:silent].present? or !params[:silent]
            if msg.empty?
              flash[:notice] = notice if notice and resource.display_name != 'QRID'
            else
              msg.each { |key, value| flash[key] = value }
            end
          end
          if params[:return_path].present?
            redirect_to(params[:return_path])
          else
            redirect_to(location ? location : url_for(controller: controller_name, action: :index))
          end
        end
        format.js do
          if !params[:silent].present? or !(params[:silent] == "true")
            if msg.empty?
              flash.now[:notice] = notice if notice
            else
              msg.each { |key, value| flash.now[key] = value }
            end
          end
        end
      end
    end
  end
end
