class Tenant::SupportController < Tenant::BaseController
  
  def request_feature
    headers['Last-Modified'] = Time.now.httpdate
    respond_to do |format|
      format.js {
        @s3_direct_post = S3_BUCKET.presigned_post(key: "support/#{Apartment::Tenant.current_tenant}/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :private).where(:content_type).starts_with("")

        case request.method.downcase.to_sym
          when :get
            @request = Tenant::Support::Request.new
            @request.email = current_user.email if current_user
            @request.company = Admin::Tenant.cached_find_by_host(request.host).company_name
            render :request
          when :post, :patch
            @request = Tenant::Support::Request.new(request_params)
            if @request.validate! > 0
              full_msg = ''          
              @request.errors.values.flatten.each do |msg|
                full_msg << msg << '<br>'.html_safe                        
              end

              flash.now[:alert] = full_msg
              render :request
            else                  
              if request_params[:screenshot].present?
                ss = OpenStruct.new
                ss.screenshot_url = request_params[:screenshot]
                # ss.original_name = File.basename(request_params[:screenshot].original_filename).sub(/[^\w\.\-]/,'_')
                # ss.directory = 'public/support/screenshots/'
                # ss.timestamp = Time.now.to_i
                # ss.basename = ss.timestamp.to_s + '_' + ss.original_name
                # ss.path = File.join(ss.directory,ss.basename)
                # FileUtils.mkdir_p ss.directory
                # File.open(ss.path, "wb") do |file|
                #   file.write(request_params[:screenshot].read)
                # end 
              else
                ss = nil               
              end
              ::Tenant::Support::Mailer.delay.request_feature(::Tenant::Support::Request.new(request_params), current_user.email, ss)
              render :request_thanks
            end
        end 
      }
    end
  rescue => ex
    flash.now[:alert] = 'The click path taken to this page is invalid.  Please check the site map and try again.'
    render :error
  end
  
  def report_bug
    headers['Last-Modified'] = Time.now.httpdate
    respond_to do |format|
      format.js {
        @s3_direct_post = S3_BUCKET.presigned_post(key: "support/#{Apartment::Tenant.current_tenant}/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :private).where(:content_type).starts_with("")

        case request.method.downcase.to_sym
          when :get
            @report = Tenant::Support::Report.new
            @report.email = current_user.email if current_user
            @report.company = Admin::Tenant.cached_find_by_host(request.host).company_name
            ua = UserAgent.parse(request.user_agent)
            @report.browser = ua.browser
            @report.os = ua.platform
            @report.browser_version = ua.version
            @report.uri = request.referer
            @report.user_agent = request.user_agent.to_s
            render :report
          when :post, :patch
            @report = Tenant::Support::Report.new(report_params)
            if @report.validate! > 0
              full_msg = ''          
              @report.errors.values.flatten.each do |msg|
                full_msg << msg << '<br>'.html_safe                        
              end

              flash.now[:alert] = full_msg
              render :request
            else      
              if report_params[:screenshot].present?
                ss = OpenStruct.new
                ss.screenshot_url = report_params[:screenshot]
                # ss.original_name = File.basename(request_params[:screenshot].original_filename).sub(/[^\w\.\-]/,'_')
                # ss.directory = 'public/support/screenshots/'
                # ss.timestamp = Time.now.to_i
                # ss.basename = ss.timestamp.to_s + '_' + ss.original_name
                # ss.path = File.join(ss.directory,ss.basename)
                # FileUtils.mkdir_p ss.directory
                # File.open(ss.path, "wb") do |file|
                #   file.write(request_params[:screenshot].read)
                # end 
              else
                ss = nil               
              end
              #abort('here!!')
              ::Tenant::Support::Mailer.delay.report_bug(::Tenant::Support::Report.new(report_params), current_user.email, ss)
              render :report_thanks
            end
        end 
      }
    end
  rescue => ex
    flash.now[:alert] = 'The click path taken to this page is invalid.  Please check the site map and try again.'
    render :error
  end
  
  private
  
  def report_params
    params.require(:tenant_support_report).permit(:name, :email, :company, :bug, :video, :screenshot, :message, :browser, :browser_version, :os, :uri,:user_agent)
  end

  def request_params
    params.require(:tenant_support_request).permit(:name, :email, :company, :screenshot, :message)
  end
end