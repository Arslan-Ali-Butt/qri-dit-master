module AuthHelpers
  def encode_credentials(username, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end