class AddStaffRefToSites < ActiveRecord::Migration
  def change
    add_reference :tenant_sites, :updated_tenant_staff, polymorphic: true
    add_reference :tenant_sites, :created_tenant_staff, polymorphic: true
  end
end
