require 'test_helper'

class Tenant::AssignmentTest < ActiveSupport::TestCase
  setup do
    @assignment = FactoryGirl.create(:assignment)
  end

  test "should be invalid without an assignee" do
    assignment = FactoryGirl.build(:assignment, assignee_id: nil)

    assert !assignment.valid?, "User is not being validated"
  end

  test "should be invalid without a qrid" do
    assignment = FactoryGirl.build(:assignment, qrid_id: nil)

    assert !assignment.valid?, "QRID is not being validated"
  end

  test "should be invalid without time range" do
    assignment = FactoryGirl.build(:assignment, start_at: nil)
    assert !assignment.valid?, "Start time is not being validated"
    assignment = FactoryGirl.build(:assignment, end_at: nil)
    assert !assignment.valid?, "End time is not being validated"
  end
end
