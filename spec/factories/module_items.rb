FactoryBot.define do
  # Note that items created via this factory persist across tests so will need to be cleaned up after each use.
  # This can be done via:
  #   after do
  #    described_class.delete_all
  #    described_class.reload(true)
  #  end
  # See: https://github.com/active-hash/active_hash#saving-in-memory-records
  factory :module_item do
    training_module { :test }
  end
end
