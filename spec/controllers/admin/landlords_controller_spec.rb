require 'rails_helper'

describe Admin::LandlordsController do

  controller do
    def authorize
      true
    end
  end

  it_behaves_like 'a CRUD resource', Admin::Landlord, :landlord, 'html'

  # describe "DELETE #destroy" do

  #   before do
  #     @landlord = create(:landlord)
  #   end

  #   it "destroys the resource" do

  #     expect {
  #       delete :destroy, id: @landlord.id, subdomain: 'test1', format: 'html'  
  #     }.to change{Admin::Landlord.count}.by(-1)
      
  #     expect(response.status).to eq(302)
  #   end
  # end

end
