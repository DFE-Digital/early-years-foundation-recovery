
class FeedbackController < ApplicationController
  
  helper_method :previous_path, :content, :is_checkbox?
    def show;
    end

    def intro; end

    def is_checkbox?
      puts content.name
      content.response_type
    end

    def update
      puts params
      puts params[:answers]

      answer_wording = []

      answers = params[:answers]
      if answers.is_a?(Array)
        answers.each do |answer|
          puts answer
          answer_wording << content.answers[answer.to_i - 1] if answer != ""
        end
      else
        answer_wording << content.answers[answers.to_i - 1]
      end

      puts answer_wording
      current_user.responses.create(answers: answer_wording)

      next_feedback
    end

    def next_feedback
      if params[:id].to_i == questions.count
        redirect_to my_modules_path
      else
        redirect_to feedback_path(params[:id].to_i + 1)
      end
    end

    def previous_path
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
  
    def content
      @content ||= questions[params[:id].to_i - 1]
    end
end


