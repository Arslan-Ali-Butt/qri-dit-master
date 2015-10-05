# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_solution, class: 'Tenant::ReportSolution' do
    association :report, factory: :report
    association :report_task, factory: :report_task
    description 'My description'
  end
end
