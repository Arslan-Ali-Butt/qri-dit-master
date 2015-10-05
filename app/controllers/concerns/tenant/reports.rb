module Tenant
  module Reports
    extend ActiveSupport::Concern

    included do
      helper_method :report_params
    end

    def report_params
      params.require(:tenant_report).tap do |whitelisted|
        whitelisted[:questions]     = params[:tenant_report][:questions]
        whitelisted[:comments]      = params[:tenant_report][:comments]
        whitelisted[:is_permatask_report] = (params[:tenant_report][:is_permatask_report] == "true" or params[:tenant_report][:is_permatask_report] == true)
        whitelisted[:started_at_i] = params[:tenant_report][:started_at_i]
        whitelisted[:completed_at_i] = params[:tenant_report][:completed_at_i]
        whitelisted[:qrid_id] = params[:tenant_report][:qrid_id]
        whitelisted[:assignment_id] = params[:tenant_report][:assignment_id]
        whitelisted[:photos]      = params[:tenant_report][:photos]
      end
    end
    
  end
end