require 'test_helper'

class Tenant::QridTest < ActiveSupport::TestCase
  setup do
    @site = FactoryGirl.create(:site)
    @qrid = FactoryGirl.create(:qrid, site_id: @site.id)
  end

  test "should be invalid without a site" do
    qrid = FactoryGirl.build(:qrid, site_id: nil)

    assert !qrid.valid?, "Site is not being validated"
  end

  test "should be invalid with duplicate site" do
    qrid = FactoryGirl.build(:qrid, site_id: @site.id)

    assert !qrid.valid?, "Site cannot be duplicated"
  end
end
