class Tenant::SettingsController < Tenant::BaseController
  include Uploadable

  authorize_resource class: false
  before_action :set_tenant
  
  def index
    if request.post?
      @tenant.host_url = request.host_with_port
      begin
        if @tenant.update(tenant_params)
          begin
            customer = Chargify::Customer.find(@tenant.billing_customer_id)
            customer.email = tenant_params[:admin_email]
            customer.save
          rescue
            flash.now[:notice] = "An error occurred while updating administrative email."
          end
          flash.now[:notice] = "Company info has been updated."
        end
      rescue => ex
        flash.now[:alert] = flash.now[:alert] = 'An error occurred with our system during this process.  Please contact technical support : email support@quickreportsystems.com or phone 1-800-686-2104'
        raise ex
      end
    end

    setup_s3_upload
  end

  def create_logo
    tenant = Admin::Tenant.cached_find_by_host(request.host)

    Admin::Logo.where(tenant_id: tenant.id).destroy_all
    
    @logo = Admin::Logo.create(photo_url: params[:upload][:photo_url], tenant_id: tenant.id)

    render layout: nil
  end

  # def process_change_plan_details
  #   begin
  #     subscription_id = @tenant.process_change_plan change_plan_params
  #     if subscription_id
  #       flash.now[:notice] = 'Plan details updated successfully.'
  #       @tenant.update(priceplan_id: change_plan_params[:priceplan_id], billing_recurrence: change_plan_params[:billing_recurrence], billing_subscription_id: subscription_id)
  #     else
  #       raise Exception.new 'An error occurred while validating the credit card information you had entered.'
  #     end
  #   rescue ChargeBee::APIError => ex
  #     flash.now[:alert] = eval(ex.message.to_s)[:message].to_s
  #   rescue => ex
  #       flash.now[:alert] = ex.message
  #   ensure      
  #     flash.keep
  #     render partial: 'process_change_plan_details', format: :js
  #   end
  # end
  
  def process_change_card_details    
    customer = Stripe::Customer.retrieve(@tenant.stripe_customer_id)
    customer.source = change_card_params[:card_token]
    customer.save

    # subscription = Chargify::Subscription.find(@tenant.billing_subscription_id)
    # subscription.payment_profile.last_four = change_card_params[:card_last4]
    # subscription.payment_profile.card_type = change_card_params[:card_brand].downcase
    # subscription.payment_profile.save
      
    
    if @tenant.update({ card_last4: change_card_params[:card_last4], card_brand: change_card_params[:card_brand] }) && @tenant.errors.blank?        
      flash[:notice] = 'Card details validated then updated successfully.'        
      return        
    end

    raise Exception.new 'An error occurred while validating the credit card information you had entered.'
  rescue => ex
    flash[:alert] = ex.message
  ensure
    redirect_to tenant_settings_billing_url  
  end

  def billing
    @subscription = Chargify::Subscription.find @tenant.billing_subscription_id

    @statement_list_items = @subscription.statements.sort { |a, b| b.id.to_i <=> a.id.to_i }
  rescue => ex
    flash.now[:alert] = "An error occurred while searching for subscription data."
  end

  def show_statement
    respond_to do |format|
      format.html do
        @statement = Chargify::Statement.find(params[:id])
      end

      format.pdf do
        resource = RestClient::Resource.new "https://#{ENV['CHARGIFY_SUBDOMAIN']}.chargify.com/statements/#{params[:id]}.pdf", 
        ENV['CHARGIFY_API_KEY'], 'x'

        response = resource.get
        
        send_data(response, :filename => "test.pdf", :type => "application/pdf", disposition: 'inline')
      end
    end
  rescue => ex
    flash.now[:alert] = ex.message
  end
  
  private
  
  def set_tenant
    @tenant = Admin::Tenant.find_by_host(request.host)
  end

  def tenant_params
    params.require(:admin_tenant).permit(:subdomain, :company_name, :admin_email, :company_website, :phone, :phone_ext, :assignment_notification_time, :allow_reporters_to_view_reports, :allow_comment_email_notifications, :allow_clients_view_comments,:metric, :invite_clients_on_create, :timezone, :country_code,:allow_affiliate_requests)
  end

  def change_card_params
    params.require(:change_card_details).permit(:card_name, :card_token, :card_last4, :card_brand)
  end
  
  def change_plan_params
    params.require(:change_plan_details).permit(:priceplan_id, :billing_recurrence,:card_name, :card_token, :card_last4, :card_brand, :billing_coupon, :billing_coupon)
  end
end