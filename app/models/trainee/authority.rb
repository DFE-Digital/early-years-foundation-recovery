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
  end
end
