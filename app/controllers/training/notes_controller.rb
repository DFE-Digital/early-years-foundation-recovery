class Training::NotesController < ApplicationController
  include Learning

  before_action :authenticate_registered_user!

  helper_method :note,
                :content

  # GET /my-account/learning-log
  def show
    @training_modules = current_user.active_modules
    render 'notes/show'
  end

  # POST /my-account/learning-log
  def create
    nav_keys = %i[next_page_name next_page_module module_item_id]
    attrs = note_params.except(*nav_keys)
    note_instance = existing_note || Note.new(attrs)
    if note_instance.save
      track('user_note_created')
      redirect_to next_page_path
    else
      Rails.logger.error("Learning log save failed for user #{current_user.id}: #{note_instance.errors.full_messages.join(', ')}")
      render_current_page
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    nav_keys = %i[next_page_name next_page_module module_item_id]
    attrs = note_params.except(*nav_keys)
    if note.update(attrs)
      track('user_note_updated')
      redirect_to next_page_path
    else
      Rails.logger.error("Learning log update failed for user #{current_user.id}: #{note.errors.full_messages.join(', ')}")
      render_current_page
    end
  end

private

  # @see Learning
  # @return [String]
  def content_name
    note_params[:name]
  end

  # @see Learning
  # @return [String]
  def mod_name
    note_params[:training_module]
  end

  # @return [String]
  def next_page_path
    # Prefer next page info from form, fallback to current page
    if note_params[:next_page_module].present? && note_params[:next_page_name].present?
      training_module_page_path(note_params[:next_page_module], note_params[:next_page_name])
    elsif note_params[:training_module] && note_params[:name]
      training_module_page_path(note_params[:training_module], note_params[:name])
    else
      user_notes_path
    end
  end

  # defensive
  def render_current_page
    render "training/pages/#{params[:page_type] || 'content'}", local: { note: note }
  end

  # @return [Note]
  def note
    nav_keys = %i[next_page_name next_page_module module_item_id]
    attrs = note_params.except(*nav_keys)
    existing_note || Note.new(attrs)
  end

  # @return [Note]
  def existing_note
    current_user.notes.find_by(training_module: note_params[:training_module], name: note_params[:name])
  end

  # @see Tracking
  # @return [Hash]
  def tracking_properties
    {
      length: note_params[:body].length,
      **note_params.except(:body, :module_item_id, :user),
    }
  end

  def note_params
    params.require(:note)
      .permit(:title, :body, :training_module, :name, :module_item_id, :next_page_name, :next_page_module)
      .with_defaults(user: current_user)
  end
end
