class Guest < Dry::Struct
  # @return [Boolean]
  def guest?
    true
  end

  # @return [String]
  def id
    current_visit.visitor_id
  end
end
