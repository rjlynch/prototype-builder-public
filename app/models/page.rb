class Page < ApplicationRecord
  belongs_to :wizard
  has_many :components, -> { order(:position) }, dependent: :destroy, inverse_of: :page

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :wizard_id }
  validates :title, length: { maximum: 500 }
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
end
