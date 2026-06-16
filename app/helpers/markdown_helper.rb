module MarkdownHelper
  # Renders the tiny markdown subset the builder supports — **bold** and
  # [links](target) — as safe GOV.UK HTML. Everything else is plain text.
  #
  # Content is HTML-escaped first, then only the known-safe <strong>/<a> tags
  # are introduced, so user input can never inject markup. Pass the owning
  # `page` so internal link targets (page slugs, #heading anchors) resolve.
  def govuk_markdown(text, page: nil)
    return "".html_safe if text.blank?

    html = ERB::Util.html_escape(text)

    html = html.gsub(/\*\*(.+?)\*\*/) do
      %(<strong class="govuk-!-font-weight-bold">#{$1}</strong>)
    end

    html = html.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
      label = Regexp.last_match(1)
      href = markdown_href(Regexp.last_match(2), page)
      %(<a class="govuk-link" href="#{href}">#{label}</a>)
    end

    html.html_safe
  end

  private

  # Resolves a markdown link target to an href. Full URLs, root-relative paths
  # and #heading anchors pass through; anything else is treated as a page slug
  # in the same wizard and linked to that page (or left inert if unknown), so
  # an unrecognised target — including a `javascript:` scheme — never becomes a
  # live link.
  def markdown_href(target, page)
    return target if target.start_with?("http://", "https://", "mailto:", "/", "#")

    destination = page&.wizard&.pages&.find_by(slug: target)
    destination ? page_path(destination) : "#"
  end
end
