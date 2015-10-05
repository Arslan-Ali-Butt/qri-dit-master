module Tenant::HelpHelper
  def tenant_help_link(text, url, action)
    link_to text, url, class: (current_page?(action: action) ? 'active' : '')
  end
end
