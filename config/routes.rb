Rails.application.routes.draw do
  # Route pour le sidebar standard (lié à un projet par exemple)
  scope '/sidebar' do
    get  '/:id/edit',    to: 'sidebar#edit',    as: 'edit_sidebar'
    post '/:id/edit',    to: 'sidebar#edit'

    get  '/:id/preview', to: 'sidebar#preview', as: 'preview_sidebar'
    post '/:id/preview', to: 'sidebar#preview'

    get  '/:id/pages',   to: 'sidebar#pages',   as: 'sidebar_pages'
    post '/:id/pages',   to: 'sidebar#pages'
  end

  # Route pour le global_sidebar (sans id, accès global)
  get  '/global_sidebar/pages', to: 'global_sidebar#pages', as: 'global_sidebar_pages'
  post '/global_sidebar/pages', to: 'global_sidebar#pages'
end
