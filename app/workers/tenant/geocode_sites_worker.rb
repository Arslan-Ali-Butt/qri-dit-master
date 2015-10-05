class Tenant::GeocodeSitesWorker
  
  include Sidekiq::Worker

  def perform
    
    num_tries = 10    # we will try 10 times before raising an error

    wait_periods = exp_backoff(num_tries)

    n = 0
    Tenant::Site.all.each do |site|
      # geocode all sites
      
      while site.latitude.blank? or site.longitude.blank?
        site.geocode
        if site.latitude.present? and site.longitude.present?
          site.save 
        else
          sleep wait_periods[0]
          n += 1

          if n >= num_tries
            raise "Failed to complete geocoding for site #{site.id} after #{num_tries} tries"
          end
        end
      end
    end

  end

  def exp_backoff(upto)
  
    result = [ ]
    # ^ stores wait periods
   
    (1..upto).each do |iter|
      result << (1.0/ 2.0* (2.0**iter - 1.0)).ceil
      # using ceil to round off
    end
    
    return result
   
  end
end