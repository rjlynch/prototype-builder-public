class WizardsController < ApplicationController
  before_action :require_sign_in

  def index
    render :index, locals: { wizards: [] }
  end
end
