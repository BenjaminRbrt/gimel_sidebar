class SidebarController < ApplicationController
  menu_item :settings, only: :pages

  before_action :find_project
  before_action :find_sidebar_content, except: :pages
  before_action :find_sidebar_visibility, only: :pages
  before_action :authorize

  def edit
    logger.info "edit"
    if sidebar_params[:content_type].present?
      logger.info "edit if sidebar_params[:content_type].present?"
      if @sidebar
        logger.info "edit if sidebar"
        if @sidebar.update(sidebar_params)
          logger.info "edit if sidebar update"
          flash[:notice] = l(:notice_successful_update)
        end
      else
        logger.info "edit else !sidebar"
        @sidebar = SidebarContent.new(sidebar_params.merge(project: @project))
        if @sidebar.save
          logger.info "edit sidebar save"
          flash[:notice] = l(:notice_successful_create)
        end
        unless @sidebar.save
          logger.error "Sidebar save failed: #{@sidebar.errors.full_messages.join(', ')}"
        end
      end
    else
      logger.info "edit else !sidebar_params[:content_type].present?"
      if @sidebar&.destroy
        logger.info "edit if destroy"
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
        logger.info "controller edit"
        render partial: 'projects/settings/sidebar'
      end
    end
  end

  def preview
    logger.info "preview"
    logger.info "Params dans preview: #{params.inspect}"
    return render_403 unless params[:sidebar]

    @previewed = @sidebar

    case params[:sidebar][:content_type]
    when 'text'
      logger.info "text"
      @text = params[:sidebar].dig(:content, :text)
      render partial: 'common/preview'
    when 'wiki'
      logger.info "wiki"
      page = @project&.wiki && params[:sidebar][:content] ? @project.wiki.find_page(params[:sidebar][:content][:wiki]) : nil
      @text = page&.text.to_s
      render partial: 'common/preview'
    when 'html'
      logger.info "html"
      html = "<fieldset class=\"preview\"><legend>#{l(:label_preview)}</legend>"
      html << (params[:sidebar].dig(:content, :html) || '')
      html << "</fieldset>"
      render html: html.html_safe
    else
      logger.info "Aucun"
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
    params.require(:sidebar).permit(:content_type, :location, content: [:text, :wiki, :html])
  end
  
end
