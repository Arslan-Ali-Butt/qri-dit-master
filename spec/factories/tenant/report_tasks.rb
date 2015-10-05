# # Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_task, class: 'Tenant::ReportTask' do
    association :report, factory: :report
    task_id 1
    task_type 'Question'
    name 'How much wood would a woodchuck chuck'
    description 'My description'
  end
end
