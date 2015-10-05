module Crudable
  extend ActiveSupport::Concern

  included do
    
    def destroy
      begin
        @resource.destroy
        respond_smart_with @resource
      rescue Exception => e
        respond_smart_with @resource, alert: e.message
      end
    end

  end
end