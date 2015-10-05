# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_note, class: 'Tenant::ReportNote' do
    association :report, factory: :report
    association :author, factory: :client
  end
end
