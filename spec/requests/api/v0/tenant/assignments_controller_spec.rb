require 'rails_helper'

describe Api::V0::Tenant::AssignmentsController do

  before do
    @user = create(:staff, password: '12345678', password_confirmation: '12345678')
    @http_headers = { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "X-API-KEY" => @user.api_tokens.first.token }
  end

  describe "#index" do

    context "assignments can be returned" do
      before do
        @assignments = []

        5.times do ||
          @assignments << create(:assignment, assignee: @user)
        end

        get v0_api_tenant_assignments_path, {}, @http_headers
      end

      it_behaves_like 'an HTTP OK request'
      it_behaves_like 'an index request'

      it "returns a valid json response" do
        json = JSON.parse(response.body)

        expect(json[0].to_json).to have_json_path('title')
        expect(json[0].to_json).to have_json_path('start')
        expect(json[0].to_json).to have_json_path('end')
        expect(json[0].to_json).to have_json_path('assignee_id')
        expect(json[0].to_json).to have_json_path('qrid_id')
        expect(json[0].to_json).to have_json_path('qrid_name')
        expect(json[0].to_json).to have_json_path('comment')
        expect(json[0].to_json).to have_json_path('assignee')
        expect(json[0].to_json).to have_json_path('status')
        expect(json[0].to_json).to have_json_path('site')
        expect(json[0].to_json).to have_json_path('latitude')
        expect(json[0].to_json).to have_json_path('longitude')
        expect(json[0].to_json).to have_json_path('work_type')
        expect(json[0].to_json).to have_json_path('recurrence')
      end
    end

    context "no assignments to return" do
      before do
        get v0_api_tenant_assignments_path, {}, @http_headers
      end

      it_behaves_like 'an HTTP No Content request'
    end
  end

  describe "#show" do
    context "requested assignment exists" do
      before do
        @assignment = create(:assignment, assignee: @user)

        get v0_api_tenant_assignment_path(@assignment), {}, @http_headers
      end

      let(:id) { @assignment.id }

      it_behaves_like 'a successful show request'
    end

    context "requested assignment does not exist" do
      before do
      end

      let(:id) { '999' }

      it "throws a 404 error" do
        expect {
          get v0_api_tenant_assignment_path(id), {}, @http_headers
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
      
    end
  end
  

end
