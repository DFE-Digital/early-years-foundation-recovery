module Registration
  class ResearchParticipantForm < BaseForm
    attr_accessor :research_participant

    validates :research_participant, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(research_participant: research_participant)
    end
  end
end
