class Page < ApplicationRecord
  # GOV.UK heading sizes (https://design-system.service.gov.uk/styles/headings/),
  # largest to smallest. The H1 defaults to "l", matching the design system's
  # standard page heading.
  HEADING_SIZES = %w[ xl l m s ].freeze

  belongs_to :wizard
  has_many :components, -> { order(:position) }, dependent: :destroy, inverse_of: :page

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :wizard_id }
  validates :title, length: { maximum: 500 }
  validates :caption, length: { maximum: 500 }
  validates :heading_size, inclusion: { in: HEADING_SIZES }
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

  # The input that renders the page title as its label/legend (the GOV.UK
  # single-question pattern). First such input wins, so the title is never
  # rendered twice. Nil when the page renders its own plain H1.
  def heading_component
    components.detect { |component| component.input? && component.title_as_label? }
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
