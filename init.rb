require 'redmine'

require_dependency File.expand_path('../lib/sidebar_hook', __FILE__)

Rails.logger.info 'Starting Sidebar Content Plugin for Redmine'

Rails.application.config.after_initialize do
    Rails.logger.info 'Sidebar: entering to_prepare block'
    unless ProjectsHelper.included_modules.include?(SidebarProjectsHelperPatch)
        Rails.logger.info 'Sidebar: Including SidebarProjectsHelperPatch'
        ProjectsHelper.send(:include, SidebarProjectsHelperPatch)
    end
    unless ProjectsController.included_modules.include?(SidebarProjectsControllerPatch)
        Rails.logger.info 'Sidebar: Including SidebarProjectsControllerPatch'
        ProjectsController.send(:include, SidebarProjectsControllerPatch)
    end	
    unless Setting.included_modules.include?(SidebarSettingPatch)
        Rails.logger.info 'Sidebar: Including SidebarSettingPatch'
        Setting.send(:include, SidebarSettingPatch)
    end
end

Redmine::Plugin.register :redmine_sidebar do
  name 'Redmine Sidebar plugin'
  author '/'
  description 'sidebar custom'
  version '0.0.1'
  url 'https://github.com/BenjaminRbrt/redmine_sidebar'

  # Exemples de permissions et menus
  permission :view_redmine_sidebar, { redmine_sidebar: [:index] }, public: true
  permission :manage_sidebar, { :sidebar => [ :edit, :preview, :pages ] }, :require => :member
	
    menu :admin_menu, :sidebar,
                    { :controller => 'global_sidebar', :action => 'pages' },
                      :caption => :label_sidebar,
                      :after => :enumerations
end


