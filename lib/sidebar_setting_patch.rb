require_dependency 'setting'

module SidebarSettingPatch
  def self.included(base)
    base.class_eval do
      # Suppression de `unloadable` car il n'est plus nécessaire dans les versions récentes de Rails.
      
      # Mise à jour des paramètres disponibles
      available_settings['plugin_sidebar'] = {
        'default' => {
          :policy => :global,
          :pages  => {}
        },
        'serialized' => true
      }

      # Getter pour `plugin_sidebar`
      def self.plugin_sidebar
        self[:plugin_sidebar]
      end

      # Setter pour `plugin_sidebar`
      def self.plugin_sidebar=(v)
        setting = find_or_default(:plugin_sidebar)
        setting.value = v || ''
        setting.save(validate: false) # Dans Rails 4+ et plus, on peut utiliser `validate: false` directement
        @cached_settings[:plugin_sidebar] = nil if @cached_settings
        Rails.cache.delete("redmine/setting/plugin_sidebar") # Chemin de cache plus standardisé
        setting.value
      end
    end
  end
end
