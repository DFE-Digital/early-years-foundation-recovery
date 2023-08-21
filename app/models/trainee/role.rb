module Trainee
  class Role < Dry::Struct
    attribute :name, Types::Strict::String.constrained(filled: true)
    attribute :group, Types::Strict::String.constrained(filled: true)

    # @return [Array<Trainee::Role>]
    def self.all
      data.map { |params| new(params.symbolize_keys) }
    end

    # @return [Array<Trainee::Role>]
    def self.by_group(group)
      all.select { |role| role.group.eql?(group) }
    end

    # @return [Array<Hash>]
    def self.data
      YAML.load_file Rails.root.join('data/role-type.yml')
    end
  end
end
