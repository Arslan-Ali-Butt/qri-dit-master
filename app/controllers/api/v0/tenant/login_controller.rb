class Api::V0::Tenant::LoginController < Api::V0::BaseController
  
  def login
    if @current_user.api_tokens.count == 0
      @current_user.create_api_key
      @current_user.save!
      @current_user.reload
    end
    
    render json: { api_key: @current_user.api_tokens.first.token}, status: :ok
  end

  def ios_auth_token
    if @current_user.ios_auth_tokens.nil?
      @current_user.ios_auth_tokens = [params[:ios_auth_token]]
    else
      new_tokens = []

      @current_user.ios_auth_tokens.each do |token|
        new_tokens << token
      end

      new_tokens << params[:ios_auth_token]

      new_tokens = new_tokens.uniq

      @current_user.ios_auth_tokens = new_tokens
    end

    @current_user.save!

    render json: { success: true}, status: :ok
  end
end
