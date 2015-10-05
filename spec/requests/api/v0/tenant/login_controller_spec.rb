require 'rails_helper'

describe Api::V0::Tenant::LoginController do

  it "returns an api key when correct login credentials are provided" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    post "/login", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "Authorization" => encode_credentials(user.email, '12345678') }

    expect(response.status).to eq 200

    body = JSON.parse(response.body)
    expect(body["api_key"]).to eq user.api_tokens.first.token
  end

  it "returns a 401 response when the email address is incorrect" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    post "/login", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "Authorization" => encode_credentials('wrong@email.com', '12345678') }

    expect(response.status).to eq 401

    body = JSON.parse(response.body)
    expect(body["api_key"]).to be_nil
    expect(body["errors"]).to be_a(String)

  end

  it "returns a 401 response when the password is incorrect" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    post "/login", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'test1.example.com', "Authorization" => encode_credentials(user.email, '11111111') }

    expect(response.status).to eq 401

    body = JSON.parse(response.body)
    expect(body["api_key"]).to be_nil
    expect(body["errors"]).to be_a(String)

  end

  it "returns a 401 response when the subdomain is incorrect" do

    user = Tenant::User.new( email: 'test@abc.ca', password: '12345678', name: 'Test User')
    user.roles << Tenant::Role.create(name: 'test')
    user.save!
      
    post "/login", {}, { "HTTP_HOST" => "api.example.com", "Accept" => "application/json", 
      "X-COMPANY-DOMAIN" => 'wrong.example.com', "Authorization" => encode_credentials(user.email, '12345678') }

    expect(response.status).to eq 401

    body = JSON.parse(response.body)
    expect(body["api_key"]).to be_nil
    expect(body["errors"]).to be_a(String)
  end

end
