class NotesController < ApplicationController
  before_action :authenticate_registered_user!

  # GET /my-account/learning-log
  def show
    @training_modules = TrainingModule.active
  end

  # POST /my-account/learning-log
  def create
    @note = Note.new(note_params.except(:module_item_id))
    @model = module_item.model

    if @note.save
      track('user_notes', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else
      render "content_pages/#{module_item.type}", local: { note: @note }
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    @note = current_user.notes.where(training_module: note_params[:training_module], name: note_params[:name]).first

    if @note.update(note_params.except(:module_item_id))
      track('user_notes', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else
      render "content_pages/#{module_item.type}", local: { note: @note }
    end
  end

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
