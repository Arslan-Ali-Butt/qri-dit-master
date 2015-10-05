require 'rails_helper'

describe Tenant::PermatasksController do
  login_user(:manager)

  controller do
    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  it_behaves_like 'a CRUD resource', Tenant::Permatask, :permatask, 'html'
end
