class Training::NotesController < ApplicationController
  before_action :authenticate_registered_user!
  helper_method :note

  # GET /my-account/learning-log
  def show
    @training_modules = current_user.active_modules
    render 'notes/show'
  end

  # POST /my-account/learning-log
  def create
    @model = content

    if note.save
      track('user_note_created', **tracking_properties)
      redirect_to training_module_content_page_path(content.parent.name, content.next_item.name)
    else # not validations, so branch is not expected to be used
      render "content_pages/#{content.page_type}", local: { note: note }
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    @model = content

    if note.update(note_params.except(:module_item_id))
      track('user_note_updated', **tracking_properties)
      redirect_to training_module_content_page_path(content.parent.name, content.next_item.name)
    else # no validations, so this branch is not expected to be used
      render "content_pages/#{content.page_type}", local: { note: note }
    end
  end

private

  # common -------------------------------------

  # @return [Training::Module] shallow
  def mod
    Training::Module.by_name(mod_name)
  end

  # @return [Training::Content]
  def content
    mod.page_by_name(content_slug)
  end

  # note specific -------------------------------------

  def content_slug
    note_params[:name]
  end

  def mod_name
    note_params[:training_module]
  end

  def training_module_id
    mod_name
  end

  def note
    current_user.notes.where(training_module: mod_name, name: content_slug).first ||
    Note.new(note_params.except(:module_item_id))
  end

  def tracking_properties
    note_params.except(:body, :module_item_id, :user).merge(length: note_params[:body].length)
  end

  # Only allow a list of trusted parameters through.
  def note_params
    params.require(:note).permit(:title, :body, :training_module, :name, :module_item_id).with_defaults(user: current_user)
  end
end
