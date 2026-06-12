class Component < ApplicationRecord
  KINDS = %w[ paragraph text_input radios button ].freeze
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

  def input?
    INPUT_KINDS.include?(kind)
  end

  # True when this input supplies the page's H1 (the GOV.UK single-question
  # pattern): the first input on the page with title_as_label set.
  def page_heading?
    title_as_label? && page.heading_component == self
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
end
