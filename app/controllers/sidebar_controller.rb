class SidebarController < ApplicationController
  menu_item :settings, only: :pages

  before_action :find_project
  before_action :find_sidebar_content, except: :pages
  before_action :find_sidebar_visibility, only: :pages
  before_action :authorize

  def edit
    if sidebar_params[:content_type].present?
      if @sidebar
        if @sidebar.update(sidebar_params)
          flash[:notice] = l(:notice_successful_update)
        end
      else
        @sidebar = SidebarContent.new(sidebar_params.merge(project: @project))
        if @sidebar.save
          flash[:notice] = l(:notice_successful_create)
        end
      end
    else
      if @sidebar&.destroy
        flash[:notice] = l(:notice_successful_delete)
        @sidebar = nil
      end
    end

    respond_to do |format|
      format.html do
        redirect_to controller: 'projects', action: 'settings', id: @project, tab: 'sidebar', sidebar: sidebar_params
      end
      format.js do
        @notice = flash.discard(:notice)
        logger.info "controller edit "
        render partial: 'projects/settings/sidebar'
      end
    end
  end

  def preview
    return render_403 unless params[:sidebar]

    @previewed = @sidebar

    case params[:sidebar][:content_type]
    when 'text'
      @text = params[:sidebar].dig(:content, :text)
      render partial: 'common/preview'
    when 'wiki'
      page = @project&.wiki && params[:sidebar][:content] ? @project.wiki.find_page(params[:sidebar][:content][:wiki]) : nil
      @text = page&.text.to_s
      render partial: 'common/preview'
    when 'html'
      html = "<fieldset class=\"preview\"><legend>#{l(:label_preview)}</legend>"
      html << (params[:sidebar].dig(:content, :html) || '')
      html << "</fieldset>"
      render html: html.html_safe
    else
      render_403
    end
  end

  def pages
    @visibility ||= SidebarSetting.new(project: @project)
    if request.post?
      @visibility.pages = params[:pages]
      if @visibility.save
        flash[:notice] = l(:notice_successful_update)
      end
      redirect_back_or_to controller: 'projects', action: 'settings', id: @project, tab: 'sidebar'
    end
  end

  private

  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_sidebar_content
    @sidebar = SidebarContent.find_by(project_id: @project.id)
  end

  def find_sidebar_visibility
    @visibility = SidebarSetting.find_by(project_id: @project.id)
  end

  def sidebar_params
    params.require(:sidebar).permit(:content_type, content: [:text, :wiki, :html])
  end
end
