class Dfe
  include Pages::Base

  def initialize
    # actual_pages = Dir.entries(File.dirname(__FILE__) + '/pages').reject! { |file| file.match?(/base/) }
    # page_classes = Dir.entries(File.dirname(__FILE__) + '/pages').select { |f| !File.directory? f }.map { |x| x.gsub('.rb', '') }
    #
    # page_classes.each do |result|
    #   self.class.send(:define_method, result) do
    #   end
    # end
    # all_classes = SitePrismSubClass.results
    # base_classes = all_classes.select { |class_name| class_name.to_s =~ /Pages/ }
    # sub_class_classes = all_classes.reject { |class_name| class_name.to_s =~ /Base/ }
    # puts "This is subclasses: #{sub_class_classes}\n"
    #
    # base_classes = base_classes.reject { |base_class_name| sub_class_classes.find { |sub_class_name| sub_class_name.to_s[/::\w+/] == base_class_name.to_s[/::\w+/] } != nil }
    # puts "this is base classes: #{base_classes}"
    #
    # (base_classes + sub_class_classes).each do |result|
    #   self.class.send(:define_method, result.to_s.demodulize.underscore) do
    #     result.new
    #   end
    # end
  end
end
