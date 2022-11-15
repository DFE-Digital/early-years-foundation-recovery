class NotesController < ApplicationController
  before_action :authenticate_registered_user!
  helper_method :note

  # GET /my-account/learning-log
  def show
    @training_modules = TrainingModule.published.where(name: current_user.module_time_to_completion.keys)
  end

  # POST /my-account/learning-log
  def create
    @note = Note.new(note_params.except(:module_item_id))
    @model = module_item.model

    if @note.save
      track('user_note_created', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else # not validations, so branch is not expected to be used
      render "content_pages/#{module_item.type}", local: { note: @note }
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    @note = current_user.notes.where(training_module: note_params[:training_module], name: note_params[:name]).first
    @model = module_item.model

    if @note.update(note_params.except(:module_item_id))
      track('user_note_updated', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else # no validations, so this branch is not expected to be used
      render "content_pages/#{module_item.type}", local: { note: @note }
    end
  end

  attr_reader :note

private

  def module_item
    @module_item ||= ModuleItem.find_by(id: note_params[:module_item_id])
  end

  def tracking_properties
    note_params.except(:body, :module_item_id, :user).merge(length: note_params[:body].length)
  end

  # Only allow a list of trusted parameters through.
  def note_params
    params.require(:note).permit(:title, :body, :training_module, :name, :module_item_id).with_defaults(user: current_user)
  end
end
