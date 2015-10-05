module Tenant::BaseHelper
  def tenant_page_title(title)
    tenant = Admin::Tenant.cached_find_by_host(request.host)
    if controller.send(:_layout)
      content_for :title, "#{tenant.company_name} QRIDit Home Watch Edition Software - #{title}"
    else
      content_tag :title, "#{tenant.company_name} QRIDit Home Watch Edition Software - #{title}"
    end
  end

  def tenant_nav_link(text, url, options = nil)
    options ||= {}
    class_name = ''

    recognized = Rails.application.routes.recognize_path(url)
    if params[:controller] == recognized[:controller]
      if params[:action] == recognized[:action]
        class_name = 'active'
      elsif params[:action] == 'create' && recognized[:action] == 'new'
        class_name = 'active'
      elsif %w(show edit update).include?(params[:action]) && recognized[:action] == 'index'
        class_name = 'active'
      end
    end

    content_tag(:li, class: class_name) do
      link_to url do
        ret = ''
        ret << "<i class='fa #{options[:icon]}'></i>" if options[:icon]
        ret << "<span>#{text}</span>"
        ret << "<span class='badge'>#{options[:num]}</span>" if options[:num]
        ret.html_safe
      end
    end
  end

  def tenant_button(type, url = '', html_options = {})
    case type
      when :edit
        link_to(url, html_options.merge(class: 'btn btn-info')) do
          "<i class='fa fa-edit'></i>".html_safe
        end
      when :delete
        link_to(url, html_options.merge(class: 'btn btn-danger')) do
          "<i class='fa fa-trash-o' rel='tooltip'></i>".html_safe
        end
      when :undo_delete
        link_to(url, html_options.merge(class: 'btn')) do
          "<i class='fa fa-undo' rel='tooltip'></i>".html_safe
        end
      when :show
        link_to(url, html_options.merge(class: 'btn btn-success')) do
          "<i class='fa fa-search-plus'></i>".html_safe
        end
      when :assign
        link_to(url, html_options.merge(class: 'btn btn-warning')) do
          "<i class='fa fa-calendar'></i>".html_safe
        end
      when :time
        link_to(url, html_options.merge(class: 'btn btn-time')) do
          "<i class='fa fa-clock-o'></i>".html_safe
        end
      when :qrcode
        link_to(url, html_options.merge(class: 'btn btn-qrcode')) do
          "<i class='fa fa-qrcode'></i>".html_safe
        end
      when :photo
        link_to(url, html_options.merge(class: 'btn btn-primary')) do
          "<i class='fa fa-camera'></i>".html_safe
        end
      when :map
        link_to(url, html_options.merge(class: 'btn btn-default')) do
          "<i class='fa fa-map-marker'></i>".html_safe
        end
      when :download
        link_to(url, html_options.merge(class: 'btn btn-download', target: "_blank")) do
          "<i class='fa fa-download'></i>".html_safe
        end
      when :start
        link_to(url, html_options.merge(class: 'btn btn-primary')) do
          "<i class='fa fa-play'></i>".html_safe
        end
      when :duplicate
        link_to(url, html_options.merge(class: 'btn btn-success pull-right')) do
          "<span>Duplicate</span>".html_safe
        end
      when :print
        link_to(url, html_options.merge(class: 'btn btn-print')) do
          "<i class='fa fa-print'></i>".html_safe
        end        
      when :print_photo
        link_to(url, html_options.merge(class: 'btn')) do
          "<i class='fa fa-print'></i>".html_safe
        end
      when :meta
        link_to(url, html_options.merge(class: 'btn')) do
          "<i class='fa fa-certificate'></i>".html_safe
        end
    end
  end

  def tenant_tooltip_hint(text)
    content_tag(:span, rel: 'tooltip', title: text) do
      content_tag(:i, '', class: 'fa fa-question-circle')
    end
  end

  def resource_status_class(status)
    case status
      when 'Active'
        'label label-success'
      when 'Deleted'
        'label label-danger'
      when 'Suspended'
        'label label-warning'
      else
        'label'
    end
  end

  def html_meta_button
    str_meta_created_by = nil
    str_meta_updated_by = nil

    if @resource.try(:created_tenant_staff_id)
      # the creation happened using the depracated Statable concern method
      str_meta_created_by = Tenant::User.find(@resource.try(:created_tenant_staff_id)).try(:name)
    else
      if !@resource.nil? and @resource.versions.where("event = 'create' AND whodunnit IS NOT NULL").first.present?
        # the creation happened via paperclip
        str_meta_created_by = Tenant::User.find(@resource.versions.where("event = 'create' AND whodunnit IS NOT NULL")
          .first.whodunnit).try(:name)
      end
    end

    # we check for the update via paperclip because a recorded update via the both the old and the new tracking
    # method can co-exist
    if !@resource.nil? and @resource.versions.where("event = 'update' AND whodunnit IS NOT NULL").first.present?
      # the update happened via paperclip
      updater_id = @resource.versions.where("event = 'update' AND whodunnit IS NOT NULL").first.try(:whodunnit)

      str_meta_updated_by = Tenant::User.find(updater_id).try(:name)
    else
      if @resource.try(:updated_tenant_staff_id)
        # the update happened using the depracated Statable concern method
        str_meta_updated_by = Tenant::User.find(@resource.try(:updated_tenant_staff_id)).try(:name)
      end
    end

    # str_meta_created_by = Tenant::Staff.find(@resource.try(:created_tenant_staff_id)).try(:name) if @resource.try(:created_tenant_staff_id)
    # str_meta_updated_by = Tenant::Staff.find(@resource.try(:updated_tenant_staff_id)).try(:name) if @resource.try(:updated_tenant_staff_id)
    str_meta_created_at = @resource.created_at.to_s unless @resource.try(:created_at).blank?
    str_meta_updated_at = @resource.updated_at.to_s unless @resource.try(:updated_at).blank?
    str_meta_created_tooltip = "This #{@resource.class.name.split(/[:]{2}/)[-1].upcase} was created by #{str_meta_created_by} at #{str_meta_created_at}." unless str_meta_created_by.blank? or str_meta_created_at.blank?
    str_meta_updated_tooltip = "This #{@resource.class.name.split(/[:]{2}/)[-1].upcase} was updated by #{str_meta_updated_by} at #{str_meta_updated_at}." unless str_meta_updated_by.blank? or str_meta_updated_at.blank?
    str_meta_button_title = "#{str_meta_updated_tooltip}#{ str_meta_updated_tooltip.blank? || str_meta_created_tooltip.blank? ? "" : " "}#{str_meta_created_tooltip}"  
    return(tenant_button(:meta, '#', {renmote: true, rel: "tooltip", title: str_meta_button_title})) unless str_meta_button_title.blank?
    return(nil)
  end

end