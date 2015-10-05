class AdminLogoWorker
  
  include Sidekiq::Worker

  def perform(id)
    AdminLogoWorker.transfer_and_cleanup(id)
  end

  # Set attachment attributes from the direct upload
  # @note Retry logic handles S3 "eventual consistency" lag.
  
  def self.set_upload_attributes(id)
    
    logo = Admin::Logo.find(id)

    tries ||= 8
    
    uri = URI.parse(logo.photo_url.gsub(/[ ]/, '+'))

    key = CGI.unescape(uri.path.split('/')[1..-1].join('/'))
    file_name = uri.path.split('/')[-1..-1].first

    direct_upload_head = S3_BUCKET.objects[key].head
 
    logo.photo_file_name     = file_name
    logo.photo_file_size     = direct_upload_head.content_length
    logo.photo_content_type  = direct_upload_head.content_type
    logo.photo_updated_at    = direct_upload_head.last_modified
    logo.save

  rescue AWS::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(2)
      retry
    else
      false
    end
  end

  # Final upload processing step
  def self.transfer_and_cleanup(id)
    AdminLogoWorker.set_upload_attributes(id)
    
    logo = Admin::Logo.find(id)

    uri = URI.parse(logo.photo_url.gsub(/[ ]/, '+'))
    key = CGI.unescape(uri.path.split('/')[1..-1].join('/')) # the first array element is an empty string

    signed_photo_url = S3_BUCKET.objects[key].url_for(:read, :expires => 10*60)

    logo.photo = signed_photo_url    
    logo.save
    
    S3_BUCKET.objects[key].delete
  end
end