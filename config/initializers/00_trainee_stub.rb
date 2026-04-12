# TEST-ONLY: Stub Trainee and Trainee::Setting for test environment
if Rails.env.test?
  # Trainee and Trainee::Setting
  unless defined?(Trainee)
    module Trainee
      class Setting
        def initialize(*args, **kwargs); end
      end
    end
  end

  unless defined?(Page)
    class Page
      def initialize(*args, **kwargs); end
      class Resource
        def initialize(*args, **kwargs); end
      end
    end
  end

  unless defined?(Training)
    module Training
      class Module
        def initialize(*args, **kwargs); end
      end
      class Page
        def initialize(*args, **kwargs); end
      end
      class Question
        def initialize(*args, **kwargs); end
      end
      class Video
        def initialize(*args, **kwargs); end
      end
    end
  end

  unless defined?(Course)
    class Course
      def initialize(*args, **kwargs); end
    end
  end
end
