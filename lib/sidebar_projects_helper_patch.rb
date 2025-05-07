require_dependency 'projects_helper'
module SidebarProjectsHelperPatch
  def self.included(base)
    base.prepend(InstanceMethods)
    base.class_eval do
      alias_method :project_settings_tabs_without_sidebar, :project_settings_tabs
      alias_method :project_settings_tabs, :project_settings_tabs_with_sidebar
    end
  end

  module InstanceMethods
    def project_settings_tabs_with_sidebar
      tabs = project_settings_tabs_without_sidebar
      if User.current.allowed_to?(:manage_sidebar, @project)
        tabs.push({ :name => 'sidebar',
                    :action => :manage_sidebar,
                    :partial => 'projects/settings/sidebar',
                    :label => :label_sidebar })
      end
      tabs
    end
  end
end

