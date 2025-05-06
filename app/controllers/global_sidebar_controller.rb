class GlobalSidebarController < ApplicationController
  layout 'admin'
  menu_item :sidebar

  before_action :require_admin

  def pages
    @settings = Setting.plugin_sidebar
    logger.info "setting controller pages"
    if request.post? && params[:sidebar_settings]
      @settings = sidebar_settings_params
      Setting.plugin_sidebar = @settings
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'global_sidebar', action: 'pages'
    end
  end

  private

  def sidebar_settings_params
    logger.info "setting controller params"
    params.require(:sidebar_settings).permit!
  end
end
