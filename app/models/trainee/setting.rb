module Trainee
  class Setting < ContentfulModel::Base
    extend ::Caching

    # @return [Concurrent::Map] single shared in-memory cache
    def self.cache
      Training::Module.cache
    end

    # @return [String]
    def self.content_type_id
      'userSetting'
    end

    # @return [Array<Trainee::Setting>]
    def self.all
      fetch_or_store to_key("#{name}.__method__") do
        order(:name).load.to_a
      end
    end

    # @return [Array<Trainee::Setting>]
    def self.active
      all.select(&:active?)
    end

    # @return [Trainee::Setting, OpenStruct]
    def self.by_name(name)
      return OpenStruct.new(local_authority?: true, has_role?: true) if name.eql?('other')

      fetch_or_store to_key(name) do
        find_by(name: name).first
      end
    end

    # @return [Array<Trainee::Setting>]
    def self.by_role(role)
      find_by(role_type: role).to_a
    end

    # @return [Array<Trainee::Setting>]
    def self.with_roles
      active.select(&:has_role?)
    end

    # @note Guard clause required for container image build
    # @note "other" enables to setting_type_other field
    #
    # @return [Array<String>]
    def self.valid_types
      return [] if Rails.application.config.contentful_space.nil?

      active.map(&:name).push('other')
    end

    # @param name [String]
    # @return [Boolean]
    def self.allowed_name?(name)
      return true if name.eql?('other')

      all.any? { |setting| setting.name == name }
    end

    # @return [Boolean]
    def local_authority?
      local_authority
    end

    # @return [Boolean] childminder, other
    def has_role?
      role_type != 'none'
    end

    # @return [Boolean]
    def active?
      return true unless respond_to?(:active)

      value = ActiveModel::Type::Boolean.new.cast(active)
      value.nil? || value
    end

    # @return [Hash{Symbol => String}]
    def form_params
      {
        setting_type_id: name,
        setting_type: title,
        setting_type_other: nil,
        local_authority: (I18n.t(:na) unless local_authority?),
        role_type: (I18n.t(:na) unless has_role?),
      }
    end
  end
end
