require_dependency 'project'
require_relative '../../lib/array_text_type'

class SidebarSetting < ActiveRecord::Base
  belongs_to :project

  attribute :pages, ArrayTextType.new
# config/initializers/sanitize_sidebar_plugin_config.rb
Rails.application.config.to_prepare do
  settings = Setting.plugin_sidebar
  if settings.is_a?(Hash) && settings["pages"].is_a?(Set)
    settings["pages"] = settings["pages"].to_a
    Setting.plugin_sidebar = settings
  end
end
  
    def pages=(list)
        available_pages = SidebarPage.available_pages.collect{ |page| page.name.to_s }
        write_attribute(:pages, list ? list.select{ |page| available_pages.include?(page.to_s) } : [])
    end

    def enabled?(page)
        settings = Setting.plugin_sidebar

        case settings['policy']
        when 'global'
            settings['pages'] && settings['pages'].include?(page.to_s)
        when 'disable'
            available?(page) && (!pages || pages.include?(page.to_s))
        when 'configurable'
            available?(page) && pages && pages.include?(page.to_s)
        when 'project'
            pages && pages.include?(page.to_s)
        else
            false
        end
    end

   def available?(page)
        settings = Setting.plugin_sidebar

        case settings['policy']
        when 'project'
            true
        when 'disable', 'configurable'
            settings['pages'] && settings['pages'].include?(page.to_s)
        else
            false
        end
    end

end
