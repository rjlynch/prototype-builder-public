# Creates a wizard together with its first (blank) page, so "New wizard"
# always lands the user on a usable builder.
class WizardForm
  include ActiveModel::Model

  attr_accessor :name
  attr_reader :wizard

  validates :name, presence: true

  def save
    return false unless valid?

    @wizard = Wizard.transaction do
      Wizard.create!(name: name).tap { |wizard| wizard.pages.create!(position: 1, slug: Page.default_slug(1)) }
    end

    true
  end

  def first_page
    wizard.pages.first
  end
end
