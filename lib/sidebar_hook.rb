unless defined?(SidebarHook)
  class SidebarHook < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
      if context[:request].format == 'text/html'
        if SidebarPage.sidebar_enabled?("#{context[:controller].controller_name}/#{context[:controller].action_name}", context[:project])
          context[:controller].send(:render_to_string, :partial => 'sidebar/empty')
        end
      end

      stylesheet_link_tag('sidebar', :plugin => 'sidebar')
    end

    def view_layouts_base_sidebar(context = {})
      if context[:request].format == 'text/html'
        if !context[:controller].respond_to?(:view_context) ||
            context[:controller].view_context.content_for?(:sidebar) ||
            SidebarPage.sidebar_enabled?("#{context[:controller].controller_name}/#{context[:controller].action_name}", context[:project])
          context[:controller].send(:render_to_string, :partial => 'sidebar/base', :locals => context)
        end
      end
    end

    render_on :view_projects_show_sidebar_bottom, :partial => 'sidebar/project'
    render_on :view_issues_sidebar_issues_bottom, :partial => 'sidebar/issues'

  end
end
