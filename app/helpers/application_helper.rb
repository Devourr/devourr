module ApplicationHelper
  include User::ProfileHelper

  def current_path
    request.path
  end
end
