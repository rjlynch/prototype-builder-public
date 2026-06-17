# Receives the preview/run form: stores the page's answers in the session
# (keyed per wizard) and follows the clicked button to the next page —
# via branch rules when one matches, linearly otherwise.
class AnswersController < ApplicationController
  def create
    page = Page.find(params[:page_id])

    # Builder mode mutates the wizard (it creates missing branch targets), so it
    # needs the same team check as the rest of the builder. Run mode is the
    # public share link and stays open to anyone with the URL.
    builder = params[:mode] == "builder" && signed_in?
    authorize page, :update? if builder

    button = page.components.find_by(id: params[:button_id], kind: "button")
    answers = stored_answers(page.wizard).merge!(answer_params(page))

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
