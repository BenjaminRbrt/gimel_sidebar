require_dependency 'projects_controller'

module SidebarProjectsControllerPatch
  def self.included(base)
    base.prepend(InstanceMethods) # Utilisation de `prepend` pour les méthodes d'instance
  end

  module InstanceMethods
    def settings_with_sidebar
      settings_without_sidebar
      @sidebar ||= SidebarContent.find_by_project_id(@project.id) if @project # Vérifie que @project existe
    end
  end
end


