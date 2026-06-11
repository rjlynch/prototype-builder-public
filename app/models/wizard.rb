class Wizard < ApplicationRecord
  has_many :pages, -> { order(:position) }, dependent: :destroy, inverse_of: :wizard

  validates :name, presence: true
end
