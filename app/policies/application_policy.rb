# Base Pundit policy. The `user` passed in is the current user (see
# ApplicationController#pundit_user, currently hardcoded). Everything is denied
# by default; concrete policies opt actions in.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  # The team the user is currently working in. Authorization hangs off this:
  # a user may only act on records belonging to their current team.
  def current_team = user&.current_team

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class} must implement #resolve"
    end

    private

    attr_reader :user, :scope
  end
end
