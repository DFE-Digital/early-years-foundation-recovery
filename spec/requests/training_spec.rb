require 'rails_helper'

RSpec.describe "Trainings", type: :request do
  let(:training_module) { TrainingModule.first }

  describe "GET /modules/:training_module_id/training" do
    let(:about_training) { training_module.about_training }
    subject { get training_module_training_index_path(training_module) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "displays about training data" do
      subject
      expect(response.body).to include(about_training.title)
    end
  end

  describe "GET /modules/:training_module_id/training/:id" do
    let(:training) { training_module.trainings.first }
    let(:next_training) { training_module.trainings.to_ary[1] }
    subject { get training_module_training_path(training_module, training) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "displays training data" do
      subject
      expect(response.body).to include(training.title)
    end

    it "includes link to next training" do
      subject
      expect(response.body).to include(training_module_training_path(training_module, next_training))
    end
    
    it "does not include a link to the training recap" do
      subject
      expect(response.body).not_to include(recap_training_module_training_index_path(training_module))
    end

    context "with the last training in module" do
      let(:training) { training_module.trainings.last }

      it "renders successfully" do
        subject
        expect(response).to have_http_status(:success)
      end

      it "displays training data" do
        subject
        expect(response.body).to include(training.title)
      end

      it "includes link to the training recap" do
        subject
        expect(response.body).to include(recap_training_module_training_index_path(training_module))
      end
    end
  end

  describe "GET /modules/:training_module_id/training/recap" do
    let(:recap_training) { training_module.recap_training }
    subject { get recap_training_module_training_index_path(training_module) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "displays training recap data" do
      subject
      expect(response.body).to include(recap_training.title)
    end
  end
end
