class SettingType < YamlBase
  set_filename 'setting-type'

  def self.valid_setting_types
    all.map(&:id).push('other')
  end

  def local_authority_next?
    local_authority?
  end

  def role_type_next?
    role_type != 'none'
  end

  def self.childminder
    where(role_type: 'childminder').to_a
  end

  def self.other
    where(role_type: 'other').to_a
  end

  def self.role_type_required
    where(role_type: %i[childminder other]).to_a
  end

  def self.none
    where(role_type: 'none').to_a
  end
end
