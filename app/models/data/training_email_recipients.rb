module Data
  class TrainingEmailRecipients
    include ToCsv
    class << self
      # @return [Array<String>]
      def column_names
        %w[Email]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        result = []
        User.training_email_recipients.find_each(batch_size: 1000) do |user|
          result << {
            email: user.email,
          }
        end
        result
      end

      # @return [void]
      def export_csv
        csv_string = to_csv
        file_path = Rails.root.join('tmp/training_email_recipients.csv')
        File.write(file_path, csv_string)
      end
    end
  end
end
