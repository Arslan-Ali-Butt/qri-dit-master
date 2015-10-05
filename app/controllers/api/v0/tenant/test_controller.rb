class Api::V0::Tenant::TestController < Api::V0::BaseController
  
  def api_test
    render json: { message: "Successfully connected to the QRIDit Homewatch account for #{@tenant.company_name}"}, status: :ok
  end
end
