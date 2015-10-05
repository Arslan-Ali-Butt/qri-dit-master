module Front::BaseHelper
  def page_title(title)
    if controller.send(:_layout)
      content_for :title, "#{title} | Quick Reports System"
    else
      content_tag :title, "#{title} | Quick Reports System"
    end
  end

  def nav_link(text, url)
    class_name = current_page?(url) ? 'active' : ''
    content_tag(:li, class: class_name) do
      link_to text, url
    end
  end

  def tooltip_hint(text)
    content_tag(:span, rel: 'tooltip', title: text) do
      content_tag(:i, '', class: 'fa fa-question-circle')
    end
  end
end
