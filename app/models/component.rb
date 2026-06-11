class Component < ApplicationRecord
  KINDS = %w[ paragraph text_input button ].freeze

  belongs_to :page

  validates :kind, inclusion: { in: KINDS }
  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :page_id }
end
