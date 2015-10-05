require 'rails_helper'

describe Api::V0::Tenant::AssignmentsController do

  controller do
    def check_auth
      true
    end

    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  describe "GET #index" do

    context "no parameters provided" do

      before do
        @assignments = []
        @current_user = create(:staff)
        controller.instance_variable_set(:@current_user, @current_user)

        5.times do ||
          @assignments << create(:assignment, assignee: @current_user)
        end
      end
    
      it "assigns @resources" do
        get :index, subdomain: 'api', format: 'json'

        expect(response.status).to eq(200)
        expect(assigns(:resources)).to eq(@assignments)
      end

      it "renders the correct view" do
        get :index, subdomain: 'api', format: 'json'

        expect(response).to render_template('api/v0/tenant/assignments/index')
      end

    end

    it_behaves_like 'it has start and end timestamp filters', 'api'
    it_behaves_like 'it has an assignee_id filter', 'api'
    it_behaves_like 'it has a qrid_id filter', 'api'
  end

end
