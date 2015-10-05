class Tenant::ReportPhoto < ActiveRecord::Base
  belongs_to :report

  has_attached_file :photo,
                    path: ':database/reports/:id_partition/:hash/:style.:extension',
                    :default_url => "/images/missing.svg",
                    url: ':s3_domain_url',
                    styles: {medium: '960x640>', thumb: '100x100>'}

  validates_attachment :photo, content_type: { content_type: /\Aimage\/.*\Z/ }

  after_create :queue_processing

  Paperclip.interpolates :database do |attachment, style|
    Apartment::Tenant.current_tenant
  end

  def display_name; 'Photo' end

  def collection_id; self.task_id end

  # Final upload processing step
  def self.transfer_and_cleanup(id)
    self.set_upload_attributes(id)
    
    photo = Tenant::ReportPhoto.find(id)

    uri = URI.parse(photo.photo_url.gsub(/ /, '+'))
    key = CGI.unescape(uri.path.split('/')[1..-1].join('/')) # the first array element is an empty string

    signed_photo_url = S3_BUCKET.objects[key].url_for(:read, :expires => 10*60)

    photo.photo = signed_photo_url
    #photo.processed = true
    photo.save
    
    S3_BUCKET.objects[key].delete
  end

  protected
    # Set attachment attributes from the direct upload
    # @note Retry logic handles S3 "eventual consistency" lag.
    def self.set_upload_attributes(id)
      photo = Tenant::ReportPhoto.find(id)

      tries ||= 5
      
      uri = URI.parse(photo.photo_url.gsub(/ /, '+'))

      key = CGI.unescape(uri.path.split('/')[1..-1].join('/')) # the first array element is an empty string
      file_name = uri.path.split('/')[-1..-1].first

      direct_upload_head = S3_BUCKET.objects[key].head
   
      photo.photo_file_name     = file_name
      photo.photo_file_size     = direct_upload_head.content_length
      photo.photo_content_type  = direct_upload_head.content_type
      photo.photo_updated_at    = direct_upload_head.last_modified
      photo.save
    rescue AWS::S3::Errors::NoSuchKey => e
      tries -= 1
      if tries > 0
        sleep(3)
        retry
      else
        false
      end
    end
    
    # Queue file processing
    def queue_processing
      Tenant::ReportPhoto.delay.transfer_and_cleanup(id)
    end
end
