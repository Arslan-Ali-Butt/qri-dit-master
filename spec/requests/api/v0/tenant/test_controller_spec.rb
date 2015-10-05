require 'rails_helper'

describe Api::V0::Tenant::TestController do

  it "returns 401 when no login credentials are provided" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    get "/test", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com' }

    expect(response.status).to eq 401
  end

  it "returns 200 when login credentials are provided" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    get "/test", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "Authorization" => encode_credentials(user.email, '12345678') }

    expect(response.status).to eq 200
  end

  it "returns 401 when an invalid API token is provided provided" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    get "/test", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', 'X-API-KEY' => 'fake123' }

    expect(response.status).to eq 401
  end

  it "returns 200 when a valid auth token is provided" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.api_tokens << Tenant::ApiToken.new(token: 'testtoken123')
    user.save!
      
    get "/test", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', 'X-API-KEY' => user.api_tokens.first.token }

    expect(response.status).to eq 200
  end


end
