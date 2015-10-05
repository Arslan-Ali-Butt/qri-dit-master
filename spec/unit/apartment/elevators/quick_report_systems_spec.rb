require 'rails_helper'
require 'apartment/elevators/quick_report_systems'

describe Apartment::Elevators::QuickReportSystems do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_tenant_name" do
    context "assuming a tenant specific subdomain" do

      it "should parse subdomain" do
        tenant = ::Admin::Tenant.find_by(subdomain: 'test1')

        request = ActionDispatch::Request.new('HTTP_HOST' => 'test1.example.com')
        expect(elevator.parse_tenant_name(request)).to eq("tenant#{tenant.id}")
      end

      it "should return nil when no subdomain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
        expect(elevator.parse_tenant_name(request)).to be_nil
      end

      it "should return nil when raw IP address" do
        request = ActionDispatch::Request.new('HTTP_HOST' => '123.123.123.123')
        expect(elevator.parse_tenant_name(request)).to be_nil
      end

      it "should return nil with an invalid subdomain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'fake.bar.com')
        expect(elevator.parse_tenant_name(request)).to be_nil
      end      

      it "should parse subdomain from header for API" do
        tenant = ::Admin::Tenant.find_by(subdomain: 'test2')

        request = ActionDispatch::Request.new('HTTP_HOST' => 'api.example.com', 'HTTP_X_COMPANY_DOMAIN' => 'test2.example.com')
        expect(elevator.parse_tenant_name(request)).to eq("tenant#{tenant.id}")
      end

      it "should ignore header if passed to a web client" do
        tenant = ::Admin::Tenant.find_by(subdomain: 'test2')

        request = ActionDispatch::Request.new('HTTP_HOST' => 'test2.example.com', 'HTTP_X_COMPANY_DOMAIN' => 'test1.example.com')
        expect(elevator.parse_tenant_name(request)).to eq("tenant#{tenant.id}")
      end

    end
  end

  describe "#call" do
    it "switches to the proper tenant for web clients" do
      tenant = ::Admin::Tenant.find_by(subdomain: 'test1')

      expect(Apartment::Tenant).to receive(:switch).with("tenant#{tenant.id}")
      elevator.call('HTTP_HOST' => 'test1.example.com')
    end

    it "switches to the proper tenant for API clients" do
      tenant = ::Admin::Tenant.find_by(subdomain: 'test1')

      expect(Apartment::Tenant).to receive(:switch).with("tenant#{tenant.id}")
      elevator.call('HTTP_HOST' => 'api.example.com', 'HTTP_X_COMPANY_DOMAIN' => 'test1.example.com')
    end
  end
end