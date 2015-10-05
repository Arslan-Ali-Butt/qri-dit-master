class Front::SignupController < Front::BaseController
  before_filter :process_sequence
  ISCHECKED = 1
  def purchase
  	@priceplan = Admin::Priceplan.find_by(name: 'qridit-base-plan')
    render 'purchase', layout: 'front/base'
  end

  def subregion_select
    render 'subregion_select', layout: false
  end

  # def validate_purchase_form
  #   @error_message = ''
  #   @error_message << '<p>Please select a price plan and billing cycle.</p>' unless params[:plan].present? && params[:recurrence].present?
  #   @error_message << '<p>Please enter your first name.</p>' unless signup_params[:first_name].present?
  #   @error_message << '<p>Please enter your last name.</p>' unless signup_params[:last_name].present?
  #   @error_message << '<p>Please enter a subdomain that is entirely unique comprised of only letters and the dash character with no consecutive dashes.</p>' unless signup_params[:subdomain].present? && !Admin::Tenant.find_by(subdomain: signup_params[:subdomain].downcase) && signup_params[:subdomain].downcase.match('^[a-z\d]+(-[a-z\d]+)*$')
  #   @error_message << '<p>Please enter your company name.</p>' unless signup_params[:company_name].present?
  #   @error_message << '<p>Please enter your phone number.</p>' unless signup_params[:phone].present?
  #   @error_message << '<p>Please, enter a unique and valid email address.</p>' unless signup_params[:admin_email].present? && signup_params[:admin_email].downcase.match('\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z') && Admin::Tenant.find_by(:admin_email => signup_params[:admin_email]).nil?
  #   if signup_params[:phone_ext].present?
  #     @error_message << '<p>Please, enter a valid extension.</p>' unless signup_params[:phone_ext].match('\d{1,8}')
  #   end
  #  !(@error_message.length > 0)
  # end

  def validate_confirmation_form
    @error_message = ''
    @error_message << '<p>To continue you must agree to the Terms and Conditions of QRIDit Home Watch Edition.' unless signup_params[:tac].present? && signup_params[:tac].to_i == Front::SignupController::ISCHECKED
    !(@error_message.length > 0)
  end

  def validate_details_form
    @error_message = ''
    @error_message << '<p>Please, enter the billing address country.</p>' unless signup_params[:billingaddress_country].present?
    @error_message << '<p>Please, enter the billing address state/province.</p>' unless signup_params[:billingaddress_state].present?
    @error_message << '<p>Please, enter the billing address city.</p>' unless signup_params[:billingaddress_city].present?
    @error_message << '<p>Please, enter the billing address zip/postal code.</p>' unless signup_params[:billingaddress_zip].present?
    !(@error_message.length > 0)
  end

  def tac
    render 'tac', layout: false
  end
  
  def details
    if params[:plan].present?
      @tenant.priceplan_id = Admin::Priceplan.find_by(name: params[:plan]).id 
    elsif signup_params[:priceplan_id].present?
      @tenant.priceplan_id = Admin::Priceplan.find(signup_params[:priceplan_id]).id 
    else
      @tenant.priceplan_id = Admin::Priceplan.find_by(name: 'qridit-base-plan').id 
    end
  
    if params[:recurrence].present?
      @tenant.billing_recurrence = Admin::Tenant::PAYMENT_RECURRENCE.index(params[:recurrence])
    elsif signup_params[:billing_recurrence].present?
        @tenant.billing_recurrence = signup_params[:billing_recurrence]
    end

    if !@tenant.valid? && !flash.alert && !params[:review]
      flash.clear

      flash.alert = @tenant.errors.full_messages.map{ |message| "<p>#{message}</p>" }.join

      params[:review] = true
      redirect_to signup_url(params)      
    else
      render 'details', layout: 'front/base'
    end
  end  

  def confirmation
    if !validate_details_form && !flash.alert && !params[:review]
      flash.clear
      flash.alert = @error_message
      params[:review] = true
      redirect_to signup_details_url(params)
    else
      # opts = {
      #   :subscription => {
      #     :plan_id => 'qridit_home_watch_edition_' + Admin::Priceplan.find(@tenant.priceplan.id).name + '_' + Admin::Tenant::PAYMENT_RECURRENCE[@tenant.billing_recurrence.to_i]
      #   },
      #   :customer => {
      #       :email => @tenant.admin_email,
      #       :phone => @tenant.cardholder_telephone
      #    }
      # }

      # opts[:coupons] = @tenant.billing_coupon if CouponValidator::active?(@tenant.billing_coupon,@tenant.admin_email)
      # tax_table_file = File.join(Rails.root, 'config', 'taxes.yml')      
      # tax_table = YAML.load(File.open(tax_table_file)) if File.exists?(tax_table_file)
      # if @tenant.billingaddress_country == 'CA'
      #   opts[:subscription][:addons] = []
      #   tax_table[@tenant.billingaddress_state][Admin::Tenant::PAYMENT_RECURRENCE[@tenant.billing_recurrence.to_i]][Admin::Priceplan.find(@tenant.priceplan_id).name].each do |tax|
      #     opts[:subscription][:addons] += [{:id => tax}]
      #   end
      # end

      # result = ChargeBee::Estimate.create_subscription({ :subscription => opts })
      # @estimate = result.estimate
      @priceplan = Admin::Priceplan.find_by(name: 'qridit-base-plan')
      render 'confirmation', layout: 'front/base' #if @estimate
    end
  end

  def create
  	if @tenant.valid? && validate_confirmation_form
      @tenant.save

      
      redirect_to signup_thanks_url()
    else
      params[:review] = true
      redirect_to signup_confirmation_url(signup: signup_params), alert: '<p>Sorry, an error occurred while processing your signup request.<br><br>' + (@error_message.nil? ? '' : @error_message) + '<br>' + (@tenant.try(:errors).try(:full_messages).join('<br>')) + '</p>'
    end
  rescue => ex
    puts ex.inspect
    params[:review] = true
    redirect_to signup_confirmation_url(signup: signup_params), alert: '<p>Sorry, an error occurred while processing your signup request.  Please review the information that has been entered and try again.</p>'
  end

  def process_sequence
    if params[:action].present?
      case params[:action]
        when 'purchase'
          if params[:review].present? && params[:review]
            @tenant = Admin::Tenant.new(signup_params)
          else
            @tenant = Admin::Tenant.new
          end
        when 'details'
          @tenant = Admin::Tenant.new(signup_params)
        when 'confirmation','create'
          @tenant = Admin::Tenant.new(signup_params)
          @tenant.priceplan = Admin::Priceplan.find(@tenant.priceplan_id)
          @tenant.host_url = @tenant.subdomain + '.' + request.host_with_port.sub(/^https?\:\/\//, '').sub(/^www./,'') if !Admin::Tenant::SPECIAL_SUBDOMAINS.include?(@tenant.subdomain)
      end
    end
  end

  def signup_params       
    params.require(:signup).permit(:first_name, :last_name, :subdomain, :company_name, :company_website, :name, :phone, :phone_ext, :admin_email, :priceplan_id, :card_token, :card_brand, :card_last4, :billing_recurrence, :priceplan_id, :billingaddress_line1, :billingaddress_line2, :billingaddress_city, :billingaddress_state, :billingaddress_zip, :billingaddress_country, :billing_coupon, :tac, :country_code)
  end
end
