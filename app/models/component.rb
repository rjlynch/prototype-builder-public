class Component < ApplicationRecord
  KINDS = %w[ paragraph subheading text_input radios button ].freeze
  INPUT_KINDS = %w[ text_input radios ].freeze

  belongs_to :page
  has_many :branch_rules, -> { order(:position) }, dependent: :destroy, inverse_of: :component

  scope :inputs, -> { where(kind: INPUT_KINDS) }

  validates :kind, inclusion: { in: KINDS }
  validates :name, presence: true, if: :input?
  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :page_id }
  validate :single_page_heading, if: :title_as_label?

  def input?
    INPUT_KINDS.include?(kind)
  end

  # True when this input supplies the page's H1 (the GOV.UK single-question
  # pattern): the first input on the page with title_as_label set.
  def page_heading?
    title_as_label? && page.heading_component == self
  end

  # Whether the editor should offer the title-as-label option: once any
  # input on the page has taken it, the others stop offering it.
  def title_as_label_available?
    title_as_label? || page.heading_component.nil?
  end

  # One line identifying the component in a collapsed editor card.
  def summary_text
    return page.title if page_heading?

    input? ? label : text
  end

  # The answer key this input's value is stored and matched under.
  def input_key
    name.to_s.parameterize
  end

  # Radio options, one per line in the options column.
  def option_list
    options.to_s.lines.map(&:strip).reject(&:empty?)
  end

  # Where this button sends the user, given everything answered so far:
  # the first matching rule's target, or nil to continue linearly.
  def destination_slug(answers)
    branch_rules.detect { |rule| rule.matches?(answers) }&.target_slug
  end

  private

  # Only one input per page may render the title as its label/legend —
  # a page has one H1.
  def single_page_heading
    return if page.blank?
    return unless page.components.where(title_as_label: true).where.not(id: id).exists?

    errors.add(:title_as_label, "is already in use on this page")
  end
end
