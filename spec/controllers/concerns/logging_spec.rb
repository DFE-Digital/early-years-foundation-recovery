require 'rails_helper'

RSpec.describe Logging do
  subject(:controller) do
    Class.new {
      include Logging

      def result
        @result ||= []
      end

      attr_reader :attempt

      def action(success)
        @attempt = 0
        log_caching do
          @attempt += 1
          raise potential_error if !success && @attempt.eql?(1)

          result << success
        end
      end

      def potential_error
        [Contentful::Error, HTTP::TimeoutError].sample
      end
    }.new
  end

  describe 'wrapping an API call' do
    context 'without timeout failure' do
      it 'succeeds' do
        expect(controller.result).to be_empty
        expect { controller.action(true) }.not_to raise_error
        expect(controller.attempt).to eq 1
        expect(controller.result).to eq [true]
        controller.action(true)
        expect(controller.result).to eq [true, true]
      end
    end

    context 'with timeout failure' do
      it 'makes second attempt' do
        expect(controller.result).to be_empty
        expect { controller.action(false) }.not_to raise_error
        expect(controller.result).to eq [false]
        expect(controller.attempt).to eq 2
        controller.action(false)
        expect(controller.result).to eq [false, false]
      end
    end
  end
end
