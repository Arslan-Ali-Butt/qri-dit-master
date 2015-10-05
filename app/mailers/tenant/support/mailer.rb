class Tenant::Support::Mailer < ActionMailer::Base
 
  def request_feature(resource, reply_to, ss = nil)
    unless ss.nil?
      tries ||= 5
      ss_url=ss.screenshot_url.to_s
      if ss_url.starts_with?('//s3')
        unless ss_url.include? ENV['S3_BUCKET']
          ss_url="http://#{ENV['S3_BUCKET']}.#{ss_url[2..-1]}"
        else
          ss_url="http://#{ss_url[2..-1]}"
        end
      end
      ss_url=ss_url.gsub(' ','+')
      puts ss_url
      uri = URI.parse(ss_url)

      key = uri.path.split('/')[1..-1].join('/')
      file_name = uri.path.split('/')[-1..-1].first

      file_url = S3_BUCKET.objects[key].url_for(:read, :expires => 10*60)

      file = open(file_url).read
      attachments[file_name] = file
    end
    @resource = resource
    mail to: 'service@qridithomewatch.com', from: 'noreply@quickreportsystems.com', reply_to: reply_to, subject: 'Request a Feature'
  rescue AWS::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(3)
      retry
    else
      false
    end
  end
  
  def report_bug(resource, reply_to, ss = nil)
    unless ss.nil?
      tries ||= 5
      ss_url=ss.screenshot_url.to_s
      if ss_url.starts_with?('//s3')
        unless ss_url.include? ENV['S3_BUCKET']
          ss_url="http://#{ENV['S3_BUCKET']}.#{ss_url[2..-1]}"
        else
          ss_url="http://#{ss_url[2..-1]}"
        end
      end
      ss_url=ss_url.gsub(' ','+')
      puts ss_url
      uri = URI.parse(ss_url)

      key = uri.path.split('/')[1..-1].join('/')
      file_name = uri.path.split('/')[-1..-1].first

      file_url = S3_BUCKET.objects[key].url_for(:read, :expires => 10*60)

      file = open(file_url).read
      attachments[file_name] = file
    end
    @resource = resource
    mail to: 'support@qridithomewatch.com', from: 'noreply@quickreportsystems.com', reply_to: reply_to, subject: 'Report a Bug'
  rescue AWS::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(3)
      retry
    else
      false
    end
  end
end
