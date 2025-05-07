module SidebarProjectsControllerPatch

  def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :settings_without_sidebar, :settings
        alias_method :settings, :settings_with_sidebar
        
      end
  end

  module ClassMethods
  end

  module InstanceMethods

      def settings_with_sidebar
          settings_without_sidebar
          @sidebar ||= SidebarContent.find_by_project_id(@project.id)
      end

  end
end
