class SidebarController < ApplicationController
  menu_item :settings, only: :pages

  before_action :find_project
  before_action :find_sidebar_content, except: :pages
  before_action :find_sidebar_visibility, only: :pages
  before_action :authorize

  def edit
    logger.info "[SIDEBAR] => Action : edit"
    logger.info "[SIDEBAR] Paramètres reçus : #{sidebar_params.inspect}"
  
    if sidebar_params[:content_type].present?
      logger.info "[SIDEBAR] Content type détecté : #{sidebar_params[:content_type]}"
  
      if @sidebar
        logger.info "[SIDEBAR] Mise à jour du contenu existant (ID: #{@sidebar.id})"
        if @sidebar.update(sidebar_params)
          logger.info "[SIDEBAR] Mise à jour réussie"
          flash[:notice] = l(:notice_successful_update)
        else
          logger.warn "[SIDEBAR] Échec de la mise à jour : #{@sidebar.errors.full_messages.join(', ')}"
        end
      else
        logger.info "[SIDEBAR] Nouveau contenu à créer"
        @sidebar = SidebarContent.new(sidebar_params.merge(project: @project))
  
        if @sidebar.save
          logger.info "[SIDEBAR] Création réussie (ID: #{@sidebar.id})"
          flash[:notice] = l(:notice_successful_create)
        else
          logger.error "[SIDEBAR] Échec de la création : #{@sidebar.errors.full_messages.join(', ')}"
        end
      end
    else
      logger.info "[SIDEBAR] Aucun content_type fourni. Suppression si existant..."
      if @sidebar&.destroy
        logger.info "[SIDEBAR] Suppression réussie (ID: #{@sidebar.id})"
        flash[:notice] = l(:notice_successful_delete)
        @sidebar = nil
      else
        logger.warn "[SIDEBAR] Rien à supprimer ou suppression échouée"
      end
    end
  
    respond_to do |format|
      format.html do
        logger.info "[SIDEBAR] Redirection HTML vers l'onglet sidebar du projet"
        redirect_to controller: 'projects', action: 'settings', id: @project, tab: 'sidebar', sidebar: sidebar_params
        render partial: 'projects/settings/sidebar'
      end
      format.js do
        logger.info "[SIDEBAR] Réponse JS avec mise à jour de l'onglet sidebar"
        @notice = flash.discard(:notice)
        #render partial: 'projects/settings/sidebar'
        render action: 'edit'
      end
    end
  end

  def preview
    logger.info "[SIDEBAR] => Action : preview"
    logger.info "[SIDEBAR] Paramètres reçus : #{params.inspect}"
  
    return render_403 unless params[:sidebar]
  
    @previewed = @sidebar
    content_type = params[:sidebar][:content_type]
  
    case content_type
    when 'text'
      logger.info "[SIDEBAR][PREVIEW] Aperçu en mode texte"
      @text = params[:sidebar].dig(:content, :text)
      render partial: 'common/preview'
    when 'wiki'
      logger.info "[SIDEBAR][PREVIEW] Aperçu d'une page wiki"
      wiki_page_name = params[:sidebar].dig(:content, :wiki)
      page = @project&.wiki&.find_page(wiki_page_name)
      @text = page&.text.to_s
      render partial: 'common/preview'
    when 'html'
      logger.info "[SIDEBAR][PREVIEW] Aperçu HTML brut"
      html = "<fieldset class=\"preview\"><legend>#{l(:label_preview)}</legend>"
      html << (params[:sidebar].dig(:content, :html) || '')
      html << "</fieldset>"
      render html: html.html_safe
    else
      logger.warn "[SIDEBAR][PREVIEW] Type de contenu inconnu ou non pris en charge : #{content_type}"
      render_403
    end
  end
  
  def pages
    logger.info "[SIDEBAR] => Action : pages (visibilité)"
  
    @visibility ||= SidebarSetting.new(project: @project)
  
    if request.post?
      logger.info "[SIDEBAR] Enregistrement des pages visibles : #{params[:pages]}"
      @visibility.pages = params[:pages]
  
      if @visibility.save
        logger.info "[SIDEBAR] Visibilité enregistrée avec succès"
        flash[:notice] = l(:notice_successful_update)
      else
        logger.warn "[SIDEBAR] Échec de l'enregistrement de la visibilité"
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
    Rails.logger.info "Sidebar found: #{@sidebar.present?}"
  end

  def find_sidebar_visibility
    @visibility = SidebarSetting.find_by(project_id: @project.id)
  end

  def sidebar_params
    params.require(:sidebar).permit(:content_type, :location, content: [:text, :wiki, :html])
  end
  
end
