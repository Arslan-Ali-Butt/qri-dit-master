class Tenant::AddressController < Tenant::BaseController
  def regions
    @resources = []
    if params[:country].present?
      country = Carmen::Country.coded(params[:country])
      if country && country.subregions?
        @resources = country.subregions
      end
    end
  end
end
