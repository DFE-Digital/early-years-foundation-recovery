module Data
  class TrainingEmailRecipients
    include ToCsv
    class << self
      def column_names
        %w[Email]
      end

      def dashboard
        User.training_email_recipients.map do |user|
          {
            email: user.email,
          }
        end
      end

      def export_csv
        csv_string = to_csv
        file_path = Rails.root.join('tmp/training_email_recipients.csv')
        File.write(file_path, csv_string)
      end
    end
  end
end
