require 'rails_helper'

describe Tenant::QridPhotosController do
  login_user(:manager)

  controller do
    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  before(:each) do
    allow_any_instance_of(Tenant::QridPhoto).to receive(:queue_processing).and_return(true)
  end

  it_behaves_like 'a CRUD resource', Tenant::QridPhoto, :qrid_photo, 'js'
end
