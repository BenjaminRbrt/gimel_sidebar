class SidebarPage
  include Redmine::I18n

  attr_reader :name, :urls, :caption

  def initialize(name, urls, options = {})
    @name = name
    @urls = urls
    @caption = l(options[:caption] || "label_#{name}")
  end

  def self.available_pages
    return @available_pages if @available_pages

    @available_pages = [
      new(:news_list,        { news: :index }),
      new(:news,             { news: :show }),
      new(:version,          { versions: :show }),
      new(:files_list,       { files: :index, projects: :list_files }),
      new(:new_issue,        { issues: :new }, caption: :label_issue_new),
      new(:forums_list,      { boards: :index }),
      new(:forum,            { boards: :show, messages: :show }, caption: :label_board),
      new(:repository,       { repositories: :show }),
      new(:revisions,        { repositories: [:changes, :revisions] }, caption: :label_revision_plural),
      new(:repository_entry, { repositories: :entry }),
      new(:annotation,       { repositories: :annotate }),
      new(:differences_view, { repositories: :diff }),
      new(:settings,         { projects: :settings }),

       # AJOUTS MANQUANTS :
      new(:project_overview, { projects: :show }, caption: :label_overview),
      new(:issue_list,       { issues: :index }, caption: :label_issue_plural),
      new(:calendar,         { calendars: :show }, caption: :label_calendar),
      new(:activity,         { activities: :index }, caption: :label_activity),
      new(:wiki,             { wiki: [:show, :index] }, caption: :label_wiki),
      new(:time_entries, { timelog: :index }, caption: :label_spent_time),
      new(:contacts, { contacts: :index }, caption: :label_contact_plural)


    ]
  end

  def self.sidebar_enabled?(path, project)
    unless @path_to_page_cache
      @path_to_page_cache = {}
      available_pages.each do |page|
        page.urls.each do |controller, actions|
          Array(actions).each do |action|
            key = "#{controller}/#{action}"
            @path_to_page_cache[key] = page
          end
        end
      end
    end

    sidebar_page = @path_to_page_cache[path]
    Rails.logger.info "[SIDEBAR] PATH = #{path} → PAGE = #{sidebar_page&.name || 'NONE'}"

    return false unless sidebar_page

    global_settings = Setting.plugin_sidebar
    project_settings = project ? SidebarSetting.find_by_project_id(project.id) : nil

    case global_settings['policy']
    when 'global'
      global_settings['pages']&.include?(sidebar_page.name.to_s)
    when 'disable'
      project_settings ? project_settings.enabled?(sidebar_page.name) : global_settings['pages']&.include?(sidebar_page.name.to_s)
    when 'configurable', 'project'
      project_settings&.enabled?(sidebar_page.name)
    else
      false
    end
  end
end
