# Patches to the Redmine core.  Will not work in development mode
require_dependency 'project_patch'
require_dependency 'issue_patch'
require_dependency 'queries_controller_patch'
require_dependency 'redmine_warehouse_hook_listener'

Redmine::Plugin.register :redmine_warehouse do
  name 'Redmine Warehouse plugin'
  author 'Stepan Golovanov'
  description 'This plugin adds warehouse tab to projects to adding products. Any projects issue can refer to a product.'
  version '1.0.0'
  url 'http://github.com/Vilkelis/redmine_warehouse'
  author_url 'http://github.com/Vilkelis'

  project_module :warehouse do
    permission :view_products, :products => [:index, :show]
    permission :create_product, :products => [:new, :create]
    permission :edit_product, :products => [:edit, :update]
    permission :destroy_product, :products => :destroy
  end

  menu :project_menu, :products,
       { :controller => "products", :action => 'index' },
       :after => :issues,
       :param => :project_id,
       :caption => :warehouse_tab_title
end
