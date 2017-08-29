module ApplicationHelper
  def user_avatar(user)
    asset_path('user.jpg')
  end

  def gi_icon(icon_class)
    content_tag 'span', '', class: "glyphicon glyphicon-#{icon_class}"
  end
end
