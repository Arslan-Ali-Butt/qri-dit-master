if Rails.env.development?
  ZeroPush.auth_token = ENV["ZEROPUSH_DEV_TOKEN"]
else
  ZeroPush.auth_token = ENV["ZEROPUSH_PROD_TOKEN"]
end