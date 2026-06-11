# Decides where a button click goes next: the clicked button's first
# matching branch rule wins, otherwise the journey continues linearly to the
# next page. In builder mode (create_missing) destinations that don't exist
# yet — a branch target slug, or the next page at the end of the journey —
# are created blank, so building flows page to page without ceremony.
class ContinueForm
  include ActiveModel::Model

  attr_accessor :page, :button, :answers, :create_missing
  attr_reader :destination

  validates :page, presence: true

  def save
    return false unless valid?

    @destination = branch_destination || linear_destination
    true
  end

  private

  def branch_destination
    slug = button&.destination_slug(answers || {}).to_s.parameterize
    return nil if slug.blank?

    page.wizard.pages.find_by(slug: slug) || create_page(slug)
  end

  def linear_destination
    page.next || create_page(nil)
  end

  def create_page(slug)
    return nil unless create_missing

    position = (page.wizard.pages.maximum(:position) || 0) + 1
    base = slug.presence || Page.default_slug(position)
    page.wizard.pages.create!(position: position, slug: Page.unique_slug(page.wizard, base))
  end
end
