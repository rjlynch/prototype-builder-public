# Moves a component one place up or down within its page by swapping
# positions with its adjacent sibling. Works across gaps in the position
# sequence (deletions don't renumber), since it swaps with the next/previous
# component in order rather than with position ± 1.
class MoveComponentForm
  include ActiveModel::Model

  DIRECTIONS = %w[ up down ].freeze

  attr_accessor :component, :direction

  validate :direction_is_known
  validate :neighbour_exists

  def save
    return false unless valid?

    other = neighbour
    mine = component.position
    theirs = other.position
    Component.transaction do
      # Park at a temporary out-of-range position so the swap never collides
      # with the unique [page_id, position] index.
      component.update!(position: component.page.components.maximum(:position) + 1)
      other.update!(position: mine)
      component.update!(position: theirs)
    end
    true
  end

  private

  def neighbour
    return @neighbour if defined?(@neighbour)

    siblings = component.page.components.to_a
    index = siblings.index(component)
    @neighbour =
      if index.nil?
        nil
      elsif direction == "up"
        siblings[index - 1] if index.positive?
      elsif direction == "down"
        siblings[index + 1]
      end
  end

  def direction_is_known
    errors.add(:direction, "is not a valid move") unless DIRECTIONS.include?(direction)
  end

  def neighbour_exists
    return unless DIRECTIONS.include?(direction)

    errors.add(:base, "there is no component to swap with") if neighbour.nil?
  end
end
