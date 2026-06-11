class Component < ApplicationRecord
  KINDS = %w[ paragraph text_input radios button ].freeze
  INPUT_KINDS = %w[ text_input radios ].freeze

  belongs_to :page

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

  # The answer key this input's value is stored and matched under.
  def input_key
    name.to_s.parameterize
  end

  # Radio options, one per line in the options column.
  def option_list
    options.to_s.lines.map(&:strip).reject(&:empty?)
  end
end
