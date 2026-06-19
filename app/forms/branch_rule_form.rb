# Backs a branch rule's target field. The target slug is parameterised on the
# way in ("You are not eligible" -> you-are-not-eligible) so it lines up with
# page slugs. The rule's conditions are edited separately (ConditionForm).
class BranchRuleForm
  include ActiveModel::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "BranchRule")
  end

  def self.from_branch_rule(branch_rule)
    new(branch_rule: branch_rule, target_slug: branch_rule.target_slug)
  end

  attr_accessor :branch_rule, :target_slug

  validates :target_slug, length: { maximum: 5_000 }

  def save
    return false unless valid?

    branch_rule.update!(target_slug: target_slug.to_s.parameterize)
    true
  end
end
