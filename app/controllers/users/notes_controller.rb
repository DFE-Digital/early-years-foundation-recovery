class Users::NotesController < ApplicationController
  helper_method :note

  def show
    @user = current_user
    @training_modules = TrainingModule.all
  end

  def create
    note = User::Note.new(note_params)
    @model = module_item.model

    if note.save
      track('user_notes', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else
      render "content_pages/#{module_item.type}", local: { note: note }
    end
  end

  def update
    note = User::Note.find permitted_params[:id]
    @model = module_item.model

    if note.update(note_params)
      track('user_notes', **tracking_properties)
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else
      render "content_pages/#{module_item.type}", local: { note: note }
    end
  end

private

  def existing_note
    current_user.notes.where(training_module: training_module_name, name: note_name).first
  end

  def new_note
    User::Note.new
  end

  def note
    @note ||= existing_note || new_note
  end

  def tracking_properties
    module_item.attributes.merge(note_id: note.id)
  end

  def module_item
    @module_item ||= ModuleItem.find_by(id: permitted_params[:module_item_id])
  end

  def note_params
    permitted_params.permit(:title, :body, :training_module, :name).with_defaults(user: current_user)
  end

  def training_module_name
    permitted_params[:training_module]
  end

  def note_name
    permitted_params[:name]
  end

  def permitted_params
    params.require(:user_note).permit(:id, :module_item_id, :title, :body, :training_module, :name)
  end
end
