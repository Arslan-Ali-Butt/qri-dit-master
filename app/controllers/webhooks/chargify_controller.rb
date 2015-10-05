class Webhooks::ChargifyController < ActionController::Base
  before_action :verify_source

  
  def index
    event = params[:event]

    case event
    when 'payment_success'
      # at this point all we really want to do is to make sure a recalculation of the QRID addon price
      # is initiated in case the user has downgraded to reduce the bill in the next period

      # this is probably unnecessary though...

      # subscription = params[:payload][:subscription]

      # # figure out which apartment to use...
      # tenant = Admin::Tenant.find_by(billing_subscription_id: subscription[:id])

      # Apartment::Tenant.switch "tenant#{tenant.id}"

      # Tenant::UpdateQridsOnPlanWorker.perform_async
    when 'payment_failure'
      #TODO, implement at some point
    when 'test'
    else
      # some other event we don't currently care about
    end

    head :ok
  end

  protected
    def verify_source
      calculated_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), ENV['CHARGIFY_SHARED_SECRET'], request.raw_post)

      puts "raw request is #{request.raw_post}"
      puts "calculated_signature is #{calculated_signature}"
      puts "chargify_signature is #{request.env['HTTP_X_CHARGIFY_WEBHOOK_SIGNATURE_HMAC_SHA_256']}"

      if calculated_signature != request.env['HTTP_X_CHARGIFY_WEBHOOK_SIGNATURE_HMAC_SHA_256']
        render json: { message: "Sorry, no can do..."}, status: :bad_request
      else
        true
      end
    end
end
