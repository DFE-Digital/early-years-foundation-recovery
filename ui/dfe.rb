class Dfe
  include Pages::Base

  def initialize
    page_classes = Dir.entries("#{File.dirname(__FILE__)}/pages")
    page_classes.reject { |f| File.directory? f }.map { |x| x.gsub!('.rb', '') }
    page_classes.delete_if { |file| file.match?(/base/) }

    # NB: page names and file names must match!

    page_classes.each do |result|
      self.class.send(:define_method, result) do
        "Pages::#{result.demodulize.camelize}".constantize.new
      end
    end
  end
end
