class Page < ApplicationRecord
  # GOV.UK heading sizes (https://design-system.service.gov.uk/styles/headings/),
  # largest to smallest. The H1 defaults to "l", matching the design system's
  # standard page heading.
  HEADING_SIZES = %w[ xl l m s ].freeze

  # GOV.UK panel variants: the page H1 (and any in-panel copy) sits in a
  # coloured box at the top of the page. "success" is the shipped green
  # confirmation panel; "information" is a custom blue, left-aligned variant.
  PANEL_STYLES = %w[ none success information ].freeze

  belongs_to :wizard
  has_many :components, -> { order(:position) }, dependent: :destroy, inverse_of: :page

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :wizard_id }
  validates :title, length: { maximum: 500 }
  validates :caption, length: { maximum: 500 }
  validates :heading_size, inclusion: { in: HEADING_SIZES }
  validates :panel_style, inclusion: { in: PANEL_STYLES }
  validates :slug,
    presence: true,
    format: { with: /\A[a-z0-9][a-z0-9-]*\z/ },
    uniqueness: { scope: :wizard_id }

  # First slug that is free within the wizard: "base", "base-2", "base-3"...
  def self.unique_slug(wizard, base, except: nil)
    taken = wizard.pages.where.not(id: except&.id).pluck(:slug)
    candidate = base
    suffix = 2
    while taken.include?(candidate)
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end
    candidate
  end

  def self.default_slug(position)
    "page-#{position}"
  end

  def next
    wizard.pages.find_by(position: position + 1)
  end

  def previous
    wizard.pages.find_by(position: position - 1)
  end

  # Whether to render a GOV.UK back link at the top of the page. On by
  # default for every page that has a previous one; the first page has
  # nowhere to go back to, so it never shows one regardless of the flag.
  def show_back_link?
    back_link? && previous.present?
  end

  # The input that renders the page title as its label/legend (the GOV.UK
  # single-question pattern). First such input wins, so the title is never
  # rendered twice. Nil when the page renders its own plain H1, and nil while a
  # panel owns the title (so inputs fall back to their own labels).
  def heading_component
    return nil if panel?

    components.detect { |component| component.input? && component.title_as_label? }
  end

  # Whether the page H1 is rendered inline as an input's own label rather than
  # as a standalone heading at the top. Only a text input does this (its
  # `<h1><label>` wrapper). A radios heading instead keeps the H1 at the top and
  # points its fieldset at it with aria-labelledby, so copy can sit between the
  # heading and the options (issue #74).
  def heading_rendered_inline?
    heading_component&.kind == "text_input"
  end

  # Whether the page H1 sits inside a GOV.UK panel at the top of the page.
  def panel?
    panel_style != "none"
  end

  # The wrapper classes for the panel; "information" is a custom variant.
  def panel_class
    panel_style == "information" ? "govuk-panel app-panel--information" : "govuk-panel govuk-panel--confirmation"
  end

  # Components shown inside the panel body, below the H1, in position order.
  # Empty unless a panel is set — only then can a component be "in the panel".
  def panel_body_components
    return [] unless panel?

    components.select { |component| component.in_panel? && component.panel_eligible? }
  end

  # Components rendered in the page body, in position order: everything except
  # the ones the panel has pulled up into itself. With no panel this is simply
  # every component.
  def body_components
    components - panel_body_components
  end

  # Whether any input on the page submits a file, so the run/preview form needs
  # a multipart encoding (the raw <input type="file"> markup doesn't trigger
  # Rails' automatic detection).
  def accepts_uploads?
    components.any? { |component| component.kind == "file_upload" }
  end

  # CSS class for the page's plain H1.
  def heading_class
    "govuk-heading-#{heading_size}"
  end

  # CSS class for the caption above the heading. The caption matches the
  # heading size, but GOV.UK only ships caption-xl/l/m, so "s" reuses "m".
  def caption_class
    "govuk-caption-#{heading_size == "s" ? "m" : heading_size}"
  end
end
