module Uploadable
  extend ActiveSupport::Concern

  included do

    helper_method :setup_s3_upload

    private
    
    def setup_s3_upload
      @s3_direct_post = S3_BUCKET.presigned_post(key: "tmp/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :private).where(:content_type).starts_with("")
    end

  end
end