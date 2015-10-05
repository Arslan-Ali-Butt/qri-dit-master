# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_priceplan_addon do
    name "MyString"
    starting_number 1
    ending_number 1
    unit_price "9.99"
    priceplan nil
  end
end
