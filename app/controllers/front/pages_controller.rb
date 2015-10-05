class Front::PagesController < Front::BaseController
  def index
    @priceplans = Admin::Priceplan.order(:position)
  end

  def about
  end

  def contact
    case request.request_method_symbol().downcase
      when :get
        @contact = Front::Contact.new
        render :contact
      when :post
        @contact = Front::Contact.new(contact_params)
        if @contact.validate! > 0
          full_msg = ''          
          @contact.errors.values.flatten.each do |msg|
            full_msg << msg << '<br>'.html_safe                        
          end

          flash.now[:alert] = full_msg
          render :contact        
        else                  
          ::Contact::Mailer.contact(Front::Contact.new(contact_params)).deliver
          redirect_to :contact_thanks
        end
      when :head
        head :ok
    end
  end

  # TODO, delete this action and all its views
  def purchase
    @priceplans = Admin::Priceplan.all    
  end

  def technology
 
  end

  def contact_thanks
    render :contact_thanks
  end
  
  def features
  
  end

  def contact_params
    params.require(:contact).permit(:name,:email,:company,:zip,:source,:message)
  end
end
