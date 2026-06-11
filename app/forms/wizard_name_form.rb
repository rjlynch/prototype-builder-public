# Backs renaming a wizard from the builder.
class WizardNameForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "Wizard")
  end

  def self.from_wizard(wizard)
    new(wizard: wizard, name: wizard.name)
  end

  attr_accessor :wizard, :name

  validates :name, presence: true, length: { maximum: 200 }

  def save
    return false unless valid?

    wizard.update!(name: name)
    true
  end
end
