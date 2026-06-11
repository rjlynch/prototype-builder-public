# Backs the preview's continue button while building: moving on from a page
# finds the next page in the journey, creating a blank one if it does not
# exist yet.
class NextPageForm
  include ActiveModel::Model

  attr_accessor :page
  attr_reader :next_page

  validates :page, presence: true

  def save
    return false unless valid?

    @next_page = page.next || page.wizard.pages.create!(position: page.position + 1)
    true
  end
end
