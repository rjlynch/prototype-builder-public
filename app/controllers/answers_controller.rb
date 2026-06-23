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

    destination = return_page(page.wizard) || form.destination || page
    redirect_to builder ? edit_page_path(destination) : page_path(destination)
  end

  private

  # When the user came from a check-answers Change link, return_to carries the
  # summary page's slug — send them straight back to it (overriding normal
  # branch/linear navigation) once the changed answer is saved. Ignored when the
  # slug names no page in the wizard.
  def return_page(wizard)
    slug = params[:return_to].presence
    wizard.pages.find_by(slug: slug) if slug
  end

  def stored_answers(wizard)
    session[:answers] ||= {}
    session[:answers][wizard.id.to_s] ||= {}
  end

  # Only keys belonging to the wizard's inputs are accepted. Checkbox groups
  # submit an array of values (answers[key][]), so they are permitted as
  # arrays; every other input is a single string (an uploaded file counts as a
  # permitted scalar, and is swapped for its blob's signed id below).
  def answer_params(page)
    wizard = page.wizard
    checkbox_keys = wizard.checkbox_input_keys
    scalar_keys = wizard.input_keys - checkbox_keys

    permitted = params.fetch(:answers, ActionController::Parameters.new)
      .permit(*scalar_keys, checkbox_keys.index_with { [] })
      .to_h

    store_uploads(permitted)
  end

  # File inputs submit an UploadedFile, which can't be serialised into the
  # session cookie. Persist each via Active Storage and keep only its signed id
  # (an opaque string) as the answer, so later pages can resolve the blob and
  # play the file back. Empty file submissions arrive as "" and pass through.
  def store_uploads(answers)
    answers.transform_values do |value|
      next value unless value.respond_to?(:original_filename)

      ActiveStorage::Blob.create_and_upload!(
        io: value,
        filename: value.original_filename,
        content_type: value.content_type
      ).signed_id
    end
  end
end
