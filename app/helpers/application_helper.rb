module ApplicationHelper
  def user_avatar(user)
    if user.avatar?
      user.avatar.url
    else
      asset_path('user.jpg')
    end
  end

  def gi_icon(icon_class)
    content_tag 'span', '', class: "glyphicon glyphicon-#{icon_class}"
  end
end
