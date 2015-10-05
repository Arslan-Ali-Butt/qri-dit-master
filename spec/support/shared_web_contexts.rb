shared_examples "a CRUD resource" do |resource_klass, resource_factory, response_format|

  describe "DELETE #destroy" do

    before do
      @resource = create(resource_factory)
    end

    it "destroys the resource" do
      expect {
        delete :destroy, id: @resource.id, subdomain: 'test1', format: response_format
      }.to change{resource_klass.count}.by(-1)
      
      case response_format
      when 'html'
        expect(response.status).to eq(302)
      when 'js'
        expect(response.status).to eq(200)
      end
      
    end
  end
end