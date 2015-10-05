require 'rails_helper'

describe Admin::TenantsController do

  controller do
    def authorize
      true
    end
  end

  it_behaves_like 'a CRUD resource', Admin::Tenant, :tenant, 'html'

end
