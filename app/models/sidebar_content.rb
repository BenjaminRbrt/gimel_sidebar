class SidebarContent < ApplicationRecord
  belongs_to :project

  validates :project, :content_type, :content, :location, presence: true
  validates :content_type, inclusion: { in: %w(text wiki html) }
  validates :location, inclusion: { in: %w(project issues only_regexp except_regexp) }

  validate :validate_wiki_page

  def content=(arg)
    if arg.present? && arg.is_a?(Hash)
      value = case content_type
              when 'text' then arg['text']
              when 'wiki' then arg['wiki']
              when 'html' then arg['html']
              end
      super(value)
    end
  end

  def url_regexp=(arg)
    if arg.present? && %w(only_regexp except_regexp).include?(location)
      super(arg)
    else
      super(nil)
    end
  end

  private

  def validate_wiki_page
    return unless content_type == 'wiki' && content.present?

    unless project&.wiki&.find_page(content)
      errors.add(:content, :wiki_page_not_found)
    end
  end
end

