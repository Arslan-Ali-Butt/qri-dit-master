class AdminConstraint
  def self.matches?(request)
    request.session[:landlord_id].present?
  end
end
