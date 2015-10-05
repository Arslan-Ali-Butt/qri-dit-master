module Statable  
  extend ActiveSupport::Concern

  included do
    before_update :set_updated_staff
    before_create :set_created_staff
  end

  private
    def set_updated_staff
      self.updated_tenant_staff_id = Tenant::User.current_id      
      self.updated_tenant_staff_type = 'Tenant::Staff'
      #puts "jmcveigh, set_updated_staff"
    rescue
      # do nothing
    end

    def set_created_staff
      self.created_tenant_staff_id = Tenant::User.current_id      
      self.created_tenant_staff_type = 'Tenant::Staff'
      #puts "jmcveigh, set_created_staff"
    rescue
      # do nothing
    end
end