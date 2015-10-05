require 'rails_helper'

describe Api::V0::Tenant::QridsController do

  controller do
    def check_auth
      true
    end

    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  describe "GET #show" do

    before do
      
      @current_user = create(:reporter)
      controller.instance_variable_set(:@current_user, @current_user)

      @qrid = create(:qrid)
    end
  
    it "assigns @resource" do
      get :show, id: @qrid.id, subdomain: 'api', format: 'json'

      expect(response.status).to eq(200)
      expect(assigns(:resource)).to eq(@qrid)
    end

    it "renders the correct view" do
      get :show, id: @qrid.id, subdomain: 'api', format: 'json'

      expect(response).to render_template('api/v0/tenant/qrids/show')
    end
  end

end
