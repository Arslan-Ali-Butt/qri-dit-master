module Front::SignupHelper
  def nav_signup_step(text, active)
    class_name = active ? 'active' : 'disabled'
    content_tag(:li, class: class_name) do
      link_to text, '#'
    end
  end
end
