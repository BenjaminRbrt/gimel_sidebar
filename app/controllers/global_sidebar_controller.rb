class GlobalSidebarController < ApplicationController
  layout 'admin'
  menu_item :sidebar

  before_action :require_admin

  def pages
    @settings = Setting.plugin_sidebar

    if request.post? && params[:sidebar_settings]
      @settings = sidebar_settings_params
      Setting.plugin_sidebar = @settings
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'global_sidebar', action: 'pages'
    end
  end

  private

  def sidebar_settings_params
    # À adapter selon les clés exactes utilisées par le plugin
    params.require(:sidebar_settings).permit!
  end
end
