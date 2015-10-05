require 'rails_helper'

describe Tenant::AssignmentsController do

  login_user(:manager)

  controller do
    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  describe "GET #index" do

    context "no parameters provided" do

      before do
        @assignments = []
        
        5.times do ||
          @assignments << create(:assignment, assignee: @user)
        end
      end
    
      it "assigns @resources" do
        get :index, subdomain: 'test1', format: 'json'

        expect(response.status).to eq(200)
        expect(assigns(:resources)).to eq(@assignments)
      end

      it "renders the correct view" do
        get :index, subdomain: 'test1', format: 'json'

        expect(response).to render_template('tenant/assignments/index')
      end

    end

    it_behaves_like 'it has start and end timestamp filters', 'test1'
    it_behaves_like 'it has an assignee_id filter', 'test1'
    it_behaves_like 'it has a qrid_id filter', 'test1'
  end

end
