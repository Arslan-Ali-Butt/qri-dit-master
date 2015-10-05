class Tenant::MySitesController < Tenant::SitesController
  prepend_before_action :set_owner

  private
  def set_owner; @owner_id = current_user.try(:id) end
end
