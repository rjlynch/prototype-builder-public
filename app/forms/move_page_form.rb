# Moves a page to another position in its wizard by swapping with the page
# currently holding that position. Pages keep their slugs, so branch rules
# are unaffected; linear continuation follows the new order.
class MovePageForm
  include ActiveModel::Model

  attr_accessor :page, :position

  validate :target_is_another_page

  def save
    return false unless valid?

    other = target_page
    original = page.position
    Page.transaction do
      # Park at a temporary out-of-range position so the swap never
      # collides with the unique [wizard_id, position] index.
      page.update!(position: page.wizard.pages.maximum(:position) + 1)
      other.update!(position: original)
      page.update!(position: target_position)
    end
    true
  end

  private

  def target_position
    position.to_i
  end

  def target_page
    @target_page ||= page.wizard.pages.find_by(position: target_position)
  end

  def target_is_another_page
    errors.add(:position, "must be held by another page") if target_page.nil? || target_page == page
  end
end
