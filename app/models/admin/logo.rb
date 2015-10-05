class Admin::Logo < ActiveRecord::Base
	has_attached_file :photo,
                    path: ':database/logos/:id_partition/:hash/:style.:extension',
                    default_url: '/images/missing.svg',                    
                    url: ':s3_domain_url',
                    styles: { medium: '240x80>', thumbnail: '225x125>', large: '300x220>' }
                    
  validates_attachment :photo, content_type: { content_type: /\Aimage\/.*\Z/ }

  after_create :queue_processing

  Paperclip.interpolates :database do |attachment, style|
    Apartment::Tenant.current_tenant
  end

  protected
    # Queue file processing
    def queue_processing
      AdminLogoWorker.perform_async(id)
    end
end
