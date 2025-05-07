require_dependency 'setting'

module SidebarSettingPatch
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      available_settings['plugin_sidebar'] = {
        'default' => {
          policy: :global,
          pages: {}
        },
        'serialized' => true
      }
    end
  end

  module ClassMethods
    def plugin_sidebar
      Rails.logger.info "SidebarSettingPatch getter"
      self[:plugin_sidebar]
    end

    def plugin_sidebar=(v)
      setting = find_or_default(:plugin_sidebar)
      setting.value = v || ''
      setting.save(validate: false)
      @cached_settings[:plugin_sidebar] = nil if @cached_settings
      Rails.cache.delete("redmine/setting/plugin_sidebar")
      setting.value
    end
  end
end
