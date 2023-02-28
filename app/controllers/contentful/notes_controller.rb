class Contentful::NotesController < Contentful::BaseController
  before_action :authenticate_registered_user!
  helper_method :note

  # GET /my-account/learning-log
  def show
    @training_modules = Training::Module.ordered.reject(&:draft?)
      .select{|mod| current_user.module_time_to_completion.keys.include?(mod.name)}
  end

  # POST /my-account/learning-log
  def create
    @note = Note.new(note_params.except(:module_item_id))
    @model = content

    if @note.save
      track('user_note_created', **tracking_properties)
      redirect_to training_module_content_page_path(content.parent.name, content.next_item.name)
    else # not validations, so branch is not expected to be used
      render "content_pages/#{content.page_type}", local: { note: @note }
    end
  end

  # PATCH/PUT /my-account/learning-log
  def update
    @note = current_user.notes.where(training_module: note_params[:training_module], name: note_params[:name]).first
    @model = content

    if @note.update(note_params.except(:module_item_id))
      track('user_note_updated', **tracking_properties)
      redirect_to training_module_content_page_path(content.parent.name, content.next_item.name)
    else # no validations, so this branch is not expected to be used
      render "content_pages/#{content.page_type}", local: { note: @note }
    end
  end

  attr_reader :note

private

  def content_slug
    note_params[:name]
  end

  def mod_name
    note_params[:training_module]
  end

  def training_module_id
    mod_name
  end

  def tracking_properties
    note_params.except(:body, :module_item_id, :user).merge(length: note_params[:body].length)
  end

  # Only allow a list of trusted parameters through.
  def note_params
    params.require(:note).permit(:title, :body, :training_module, :name, :module_item_id).with_defaults(user: current_user)
  end
end
