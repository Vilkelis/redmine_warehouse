# frozen_string_literal: true

class RedmineWarehouseHookListener < Redmine::Hook::ViewListener

  render_on :view_issues_show_details_bottom, :partial => "hooks/issue_products"

end
