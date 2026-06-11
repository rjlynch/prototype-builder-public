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

    @next_page = page.next || create_next_page
    true
  end

  private

  def create_next_page
    position = page.position + 1
    slug = Page.unique_slug(page.wizard, Page.default_slug(position))
    page.wizard.pages.create!(position: position, slug: slug)
  end
end
