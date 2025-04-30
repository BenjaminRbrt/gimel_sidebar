require 'redmine'

Rails.logger.info 'Loading redmine_sidebar..'

Redmine::Plugin.register :redmine_sidebar do
  name 'redmine sidebar'
  author '/'
  description 'sidebar custom'
  version '0.0.1'
  url 'https://github.com/BenjaminRbrt/redmine_sidebar'

  # Exemples de permissions et menus
  permission :view_redmine_sidebar, { redmine_sidebar: [:index] }, public: true

  menu :top_menu, :remine_sidebar,
       { controller: 'redmine_sidebar', action: 'index' },
       caption: 'redmine_sidebar',
       if: Proc.new { User.current.logged? }
end

# Inclusion de modules dans des hooks Rails, conditionnels
Rails.application.config.to_prepare do
  require_dependency File.expand_path('../lib/redmine_sidebar/hooks', __FILE__)
end
