require 'rails_helper'

# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe ContentChanges do
  subject(:changes) { described_class.new(user: user) }

  let(:user) { instance_double(User, id: 1, visits: visits_relation, course: course) }
  let(:visits_relation) { visits_relation_for } # default: no visits
  let(:course) { instance_double(CourseProgress, available_modules: [mod], started?: false) }
  let(:mod) { double('Training::Module', first_published_at: 2.days.ago, name: 'alpha') }

  # Helper to mimic AR relation for visits
  def visits_relation_for(*visits)
    relation = double('visits_relation')
    allow(relation).to receive(:order).with(started_at: :desc).and_return(visits)
    relation
  end

  describe '#new_modules?' do
    context 'without previous visits' do
      let(:visits_relation) { visits_relation_for } # no visits

      specify { expect(changes.new_modules?).to be false }
    end

    context 'with visits predating a modules release' do
      let(:visit) { instance_double(Visit, started_at: 5.days.ago) }
      let(:visits_relation) { visits_relation_for(visit) }

      specify { expect(changes.new_modules?).to be true }
    end
  end

  describe '#new_module?' do
    let(:param) { mod }
    let(:result) { changes.new_module?(param) }

    context 'without previous visits' do
      let(:visits_relation) { visits_relation_for } # no visits

      specify { expect(result).to be false }
    end

    context 'with visits since the modules release' do
      let(:visit) { instance_double(Visit, started_at: 1.minute.ago) }
      let(:visits_relation) { visits_relation_for(visit) }

      specify { expect(result).to be false }
    end

    context 'with visits predating a modules release' do
      let(:visit) { instance_double(Visit, started_at: 5.days.ago) }
      let(:visits_relation) { visits_relation_for(visit) }

      specify { expect(result).to be true }

      context 'and a module in progress' do
        let(:course) { instance_double(CourseProgress, available_modules: [mod], started?: true) }

        specify { expect(result).to be false }
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
