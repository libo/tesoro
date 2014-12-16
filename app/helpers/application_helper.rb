module ApplicationHelper
  def navigation_menu
    if current_user.present?
      menu_items = [
        { title: 'Events', path: events_path},
        { title: 'Import/Export', path: imports_path}
      ]

      menu_items.map do |item|
        active = current_page?(item[:path]) ? 'active' : 'regular'

        content_tag(:li, class: active) do
          link_to(item[:title], item[:path])
        end
      end.join('').html_safe
    end
  end

  def alert_class_for(flash_type)
    {
      :success => 'alert-success',
      :error => 'alert-danger',
      :alert => 'alert-warning',
      :notice => 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end
end
