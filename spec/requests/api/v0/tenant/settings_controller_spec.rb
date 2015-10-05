require 'rails_helper'

describe Api::V0::Tenant::SettingsController do

  before do
    @user = create(:staff, password: '12345678', password_confirmation: '12345678')
    @http_headers = { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "X-API-KEY" => @user.api_tokens.first.token }
  end

  describe "#index" do

    context "settings can be returned" do
      before do

        get v0_api_tenant_settings_path, {}, @http_headers
      end

      it_behaves_like 'an HTTP OK request'

      it "returns a valid json response" do
        json = JSON.parse(response.body)

        expect(json['tenant_id']).to be Admin::Tenant.first.id
        expect(json['allow_reporters_to_view_reports']).to be true
        expect(json['allow_comment_email_notifications']).to be true
        expect(json['allow_clients_view_comments']).to be false
        expect(json['invite_clients_on_create']).to be true
      end
    end
  end
end
