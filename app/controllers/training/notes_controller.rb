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
    # TODO: deprecate these instance variables
    @model = content

    if note.save
      track('user_note_created', cms: true, **tracking_properties)
      redirect_to next_page_path
    else
      render_current_page
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    # TODO: deprecate these instance variables
    @model = content

    if note.update(note_params.except(:module_item_id))
      track('user_note_updated', cms: true, **tracking_properties)
      redirect_to next_page_path
    else
      render_current_page
    end
  end

private

  # -------------------------------------

  # @return [Training::Module]
  def mod
    Training::Module.by_name(mod_name)
  end

  # @return [Training::Page]
  def content
    mod.page_by_name(content_name)
  end

  #  -------------------------------------

  def content_name
    note_params[:name]
  end

  def mod_name
    note_params[:training_module]
  end

  def next_page_path
    training_module_content_page_path(mod.name, content.next_item.name)
  end

  # defensive
  def render_current_page
    render "training/pages/#{content.page_type}", local: { note: note }
  end

  def note
    existing_note || Note.new(note_params.except(:module_item_id))
  end

  def existing_note
    current_user.notes.find_by(training_module: mod.name, name: content.name)
  end

  def tracking_properties
    note_params.except(:body, :module_item_id, :user).merge(length: note_params[:body].length)
  end

  def note_params
    params.require(:note)
      .permit(:title, :body, :training_module, :name, :module_item_id)
      .with_defaults(user: current_user)
  end
end
