module ApplicationHelper
  CHANGELOG_MARKDOWN_TAGS = %w[
    a blockquote br code del em h1 h2 h3 h4 h5 h6 hr li ol p pre strong table
    tbody td th thead tr ul
  ].freeze
  CHANGELOG_PREVIEW_MARKDOWN_TAGS = (CHANGELOG_MARKDOWN_TAGS - [ "a" ]).freeze
  CHANGELOG_MARKDOWN_ATTRIBUTES = %w[href title].freeze

  def render_changelog(markdown, allow_links: true)
    html = Commonmarker.to_html(
      markdown,
      options: {
        extension: {
          header_ids: nil
        },
        render: {
          escape: true,
          hardbreaks: false,
          unsafe: false
        }
      },
      plugins: { syntax_highlighter: nil }
    )

    sanitize(
      html,
      tags: allow_links ? CHANGELOG_MARKDOWN_TAGS : CHANGELOG_PREVIEW_MARKDOWN_TAGS,
      attributes: CHANGELOG_MARKDOWN_ATTRIBUTES
    )
  end
end
