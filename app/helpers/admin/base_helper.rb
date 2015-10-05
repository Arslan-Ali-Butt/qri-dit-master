module Admin::BaseHelper
  def admin_page_title(title)
    if controller.send(:_layout)
      content_for :title, "#{title} | QRIDit Admin panel"
    else
      content_tag :title, "#{title} | QRIDit Admin panel"
    end
  end

  def admin_nav_link(text, url, icon)
    # TODO:
    # Uncomment when this bug is fixed:
    # https://github.com/rails/rails/issues/8679
    #
    # recognized = Rails.application.routes.recognize_path(url)
    # class_name = recognized[:controller] == params[:controller] ? 'active' : ''

    class_name = url["/#{params[:controller].split('/')[1]}"] ? 'active' : ''

    content_tag(:li, class: class_name) do
      link_to url do
        "<i class='fa #{icon}'></i><span class='hidden-sm'>#{text}</span>".html_safe
      end
    end
  end

  def admin_button(type, url, html_options = {})
    case type
      when :edit
        link_to(url, html_options.merge(class: 'btn btn-info')) do
          "<i class='fa fa-edit'></i>".html_safe
        end
      when :delete
        link_to(url, html_options.merge(class: 'btn btn-danger')) do
          "<i class='fa fa-trash-o'></i>".html_safe
        end
      when :resend
        link_to(url, html_options.merge(class: 'btn btn-success')) do
          "<i class='fa fa-share'></i>".html_safe
        end
    end
  end

  def current_landlord
    @current_landlord ||= Admin::Landlord.find(session[:landlord_id]) if session[:landlord_id]
    @current_landlord
  end
end
