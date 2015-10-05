require 'rails_helper'

describe Tenant::ReportSolutionsController do
  login_user(:manager)

  controller do
    def set_timezone
      Time.use_zone('UTC') { yield }
    end
  end

  it_behaves_like 'a CRUD resource', Tenant::ReportSolution, :report_solution, 'js'
end
