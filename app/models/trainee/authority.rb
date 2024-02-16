module Trainee
  class Authority < Dry::Struct
    attribute :name, Types::Strict::String.constrained(filled: true)

    # @return [Array<Trainee::Authority>]
    def self.all
      data.map { |params| new(params.symbolize_keys) }
    end

    # @return [Array<Hash>]
    def self.data
      YAML.load_file Rails.root.join('data/local-authority.yml')
    end

    # @example
    #   Sanitise LA name changes before persisting
    #     "Cumberland (previously Cumbria)" => "Cumberland"
    # @return [String]
    def persisted_name
      name.gsub(/\(.*?\)/, '').strip
    end
  end
end
