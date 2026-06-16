# Receives the preview/run form: stores the page's answers in the session
# (keyed per wizard) and follows the clicked button to the next page —
# via branch rules when one matches, linearly otherwise.
class AnswersController < ApplicationController
  def create
    page = Page.find(params[:page_id])
    button = page.components.find_by(id: params[:button_id], kind: "button")
    answers = stored_answers(page.wizard).merge!(answer_params(page))

    builder = params[:mode] == "builder" && signed_in?
    form = ContinueForm.new(page: page, button: button, answers: answers, create_missing: builder)
    form.save

    destination = form.destination || page
    redirect_to builder ? edit_page_path(destination) : page_path(destination)
  end

  private

  def stored_answers(wizard)
    session[:answers] ||= {}
    session[:answers][wizard.id.to_s] ||= {}
  end

  # Only keys belonging to the wizard's inputs are accepted.
  def answer_params(page)
    params.fetch(:answers, ActionController::Parameters.new)
      .permit(*page.wizard.input_keys)
      .to_h
  end
end
