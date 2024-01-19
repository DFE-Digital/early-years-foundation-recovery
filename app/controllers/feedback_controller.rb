
class FeedbackController

    before_action :find_course
    before_action :find_question, only: [:show, :update]

    def show

        @question = @course.feedback.find(params[:id])
    end

    def intro; end

    def update

        form.answer = params[:answer]

        if form.save
            next_step 
        else
            flash[:error] = 'Please answer the question'
            render :show
        end
    end

    def next_step

        next_question = @course.questions.where('id > ?', params[:id]).first
        if next_question
            redirect_to feedback_path(next_question)
        else
            redirect_to feedback_complete_path
        end
    end

    def previous_step

        previous_question = @course.questions.where('id < ?', params[:id]).last
        if previous_question
          redirect_to feedback_path(previous_question)
        else
          redirect_to feedback_intro_path
        end
    end

    private

    def find_course
      @course = Course.find(params[:course_id])
    end
  
    def find_question
      @question = @course.questions.find(params[:id])
    end

    def form
      @form ||= FeedbackForm.new(user: current_user, question: @question, answer: params[:answer])
    end
end


