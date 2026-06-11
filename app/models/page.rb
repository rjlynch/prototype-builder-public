class Page < ApplicationRecord
  belongs_to :wizard
  has_many :components, -> { order(:position) }, dependent: :destroy, inverse_of: :page

  validates :position,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :wizard_id }
  validates :title, length: { maximum: 500 }

  def next
    wizard.pages.find_by(position: position + 1)
  end
end
