module Training
  class ResponsesController < Contentful::BaseController
    before_action :authenticate_registered_user!, :show_progress_bar
    # before_action :track_events, only: :show
    helper_method :training_module, :current_user_response, :content

    def show; end

    def update
      if current_user_response.update(answer: user_answer)
        redirect
      else
        render :show, status: :unprocessable_entity
      end
    end

  protected

    def user_answer
      if Array(response_params[:answer]).size > 1
        response_params[:answer].compact_blank.map(&:to_i)
      else
        response_params[:answer].to_i
      end
    end

    def show_progress_bar
      @module_progress_bar = ContentfulModuleProgressBarDecorator.new(helpers.cms_module_progress(mod))
    end

    def question_name
      content.name
    end

    def current_user_response
      @current_user_response ||= current_user.responses.find_or_initialize_by(
        question_name: content_slug,
        training_module: mod_name,
      )
    end

    def response_params
      params.require(:response).permit!
    end

  private

    def redirect
      if current_user_response.assess?
        ContentfulAssessmentProgress.new(user: current_user, mod: mod).save!
      end

      if content.formative?
        redirect_to training_module_response_path(mod_name, content_slug)
      else # content.confidence? || content.summative?
        redirect_to training_module_page_path(mod_name, content.next_item.name)
      end
    end
  end
end
