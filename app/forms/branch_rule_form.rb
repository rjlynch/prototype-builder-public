# Backs a branch rule's editor fields. The target slug is parameterised on
# the way in ("You are not eligible" -> you-are-not-eligible) so it lines up
# with page slugs.
class BranchRuleForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "BranchRule")
  end

  def self.from_branch_rule(branch_rule)
    new(
      branch_rule: branch_rule,
      input_name: branch_rule.input_name,
      value: branch_rule.value,
      target_slug: branch_rule.target_slug
    )
  end

  attr_accessor :branch_rule, :input_name, :value, :target_slug

  validates :input_name, :value, :target_slug, length: { maximum: 5_000 }

  def save
    return false unless valid?

    branch_rule.update!(
      input_name: input_name.to_s,
      value: value.to_s,
      target_slug: target_slug.to_s.parameterize
    )
    true
  end
end
