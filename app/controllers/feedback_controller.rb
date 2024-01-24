
class FeedbackController < ApplicationController
  helper_method :next_feedback, :previous_feedback, :current_question

    def show;
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

    def next_feedback
      if params[:id].to_i == questions.count
        my_modules_path
      else
        feedback_path(params[:id].to_i + 1)
      end
    end

    def previous_feedback
      if params[:id] == '1'
        feedback_path(1)
      else
        feedback_path(params[:id].to_i - 1)
      end
    end

    private


    def questions
      Course.config.feedback
    end
  
    def current_question
      @current_question ||= questions[params[:id].to_i - 1]
    end

    def form
      @form ||= FeedbackForm.new(user: current_user, question: current_question, answer: params[:answer])
    end
end


