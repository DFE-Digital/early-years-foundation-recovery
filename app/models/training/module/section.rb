module Training
  class Module < ContentfulModel::Base
    class Section < ContentfulModel::Base

      # @return [String]
      def self.content_type_id
        'divider'
      end

      # @return [true]
      def divider?
        true
      end

      # @return [Boolean]
      def submodule?
        section_type.eql?('submodule')
      end

      # @return [Boolean]
      def topic?
        section_type.eql?('topic')
      end

    end
  end
end
