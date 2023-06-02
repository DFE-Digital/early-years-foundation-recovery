module Percentage
    def calculate_percentage(numerator, denominator)
      return 0 if denominator.zero?
      (numerator.to_f / denominator.to_f) * 100
    end
  
    def format_csv
        CSV.generate do |csv|
          self.each do |row|
            puts "ROW!!!!!!!"
            puts row
            csv << row.map { |cell| cell.is_a?(Float) ? "#{cell.round(2)}%" : cell }
          end
        end
    end
  end
  