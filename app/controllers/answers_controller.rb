# Receives the preview/run form: stores the page's answers in the session
# (keyed per wizard) and follows the clicked button to the next page —
# via branch rules when one matches, linearly otherwise.
class AnswersController < ApplicationController
  def create
    # FIXME - refactor
    # Lose ContinueForm reuse the InsertPageForm to create the page, if the user
    # has permission.
    # Move linear / branch destination logic into Page#destination.
    # ```
    #
    # answers = stored_answers(page.wizard).merge!(answer_params(page))
    # destination = page.destination(answers)
    #
    # return redirect_to destination if destination.present?
    #
    # if Policies::Pages.new(current_user).create?
    #   new_page = InsertPageForm.new(page).save!
    #   redirect_to new_page.slug
    # else
    #   redirect_to wizard_page_not_found_path(page.wizard)
    # end
    #
    # Remove disabling the button on the last page of the wizard, simplify the
    # code.
    #
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
