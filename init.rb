require 'redmine'

require_dependency File.expand_path('../lib/sidebar_hook', __FILE__)
require_dependency File.expand_path('../lib/sidebar_page', __FILE__)

Rails.logger.info 'Starting Sidebar Content Plugin for Redmine'

unless Setting.included_modules.include?(SidebarSettingPatch)
  Rails.logger.info 'Sidebar: Including SidebarSettingPatch early'
  Setting.include SidebarSettingPatch
end

Rails.application.config.after_initialize do
    Rails.logger.info 'Sidebar: running to_prepare block'
  
    unless String.method_defined?(:html_safe)
      Rails.logger.info 'Sidebar: Patching String'
      String.include SidebarStringHTMLSafePatch
    end
  
    unless ActionView::Base.included_modules.include?(SidebarContentHelper)
      Rails.logger.info 'Sidebar: Including SidebarContentHelper'
      ActionView::Base.include SidebarContentHelper
    end
  
    unless ProjectsHelper.included_modules.include?(SidebarProjectsHelperPatch)
      Rails.logger.info 'Sidebar: Including SidebarProjectsHelperPatch'
      ProjectsHelper.include SidebarProjectsHelperPatch
    end
  
    unless ProjectsController.included_modules.include?(SidebarProjectsControllerPatch)
      Rails.logger.info 'Sidebar: Including SidebarProjectsControllerPatch'
      ProjectsController.include SidebarProjectsControllerPatch
    end
end


Redmine::Plugin.register :gimel_sidebar do
  name 'Gimel Sidebar plugin'
  author '/'
  description 'sidebar custom'
  version '0.0.1'
  url 'https://github.com/BenjaminRbrt/gimel_sidebar'
	
  permission :view_gimel_sidebar, { gimel_sidebar: [:index] }, public: true
  permission :manage_sidebar, { :sidebar => [ :edit, :preview, :pages ] }, :require => :member
  Rails.logger.info "User #{User.current.login} has permission to manage sidebar"
  Rails.configuration.to_prepare do
    ProjectsController.prepend SidebarProjectsControllerPatch
  end	
    menu :admin_menu, :sidebar,
                    { :controller => 'global_sidebar', :action => 'pages' },
                      :caption => :label_sidebar,
                      :after => :enumerations do
  Rails.logger.info "Sidebar menu item added to admin menu"
end
end
