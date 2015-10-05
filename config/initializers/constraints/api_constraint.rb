class ApiConstraint
  def self.matches?(request)
    if request.host.split('.')[0] == 'api'
      true
    else
      false
    end
  end
end
