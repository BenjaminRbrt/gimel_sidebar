# app/controllers/sidebar_controller.rb
class SidebarController < ApplicationController
  before_action :find_project, :authorize

  def edit
    # À implémenter
  end

  def preview
    # À implémenter
  end

  def pages
    # À implémenter
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
