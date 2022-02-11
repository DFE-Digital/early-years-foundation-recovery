require 'rails_helper'

RSpec.describe "Topics", type: :request do
  let(:training_module) { TrainingModule.first }

  describe "GET /modules/:training_module_id/topics" do
    let(:about_training) { training_module.about_training }
    subject { get training_module_topics_path(training_module) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "displays about training data" do
      subject
      expect(response.body).to include(about_training.title)
    end
  end

  describe "GET /modules/:training_module_id/topic/:id" do
    let(:topic) { training_module.topics.first }
    let(:next_topic) { training_module.topics.to_ary[1] }
    subject { get training_module_topic_path(training_module, topic) }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "displays topic data" do
      subject
      expect(response.body).to include(topic.title)
    end

    it "includes link to next topic" do
      subject
      expect(response.body).to include(training_module_topic_path(training_module, next_topic))
    end
    
    it "does not include a link to the training recap" do
      subject
      expect(response.body).not_to include(recap_training_module_topics_path(training_module))
    end

    context "with the last training in module" do
      let(:topic) { training_module.topics.last }

      it "renders successfully" do
        subject
        expect(response).to have_http_status(:success)
      end

      it "displays training data" do
        subject
        expect(response.body).to include(topic.title)
      end

      it "includes link to the training recap" do
        subject
        expect(response.body).to include(recap_training_module_topics_path(training_module))
      end
    end
  end

  describe "GET /modules/:training_module_id/topic/recap" do
    let(:recap_training) { training_module.recap_training }
    subject { get recap_training_module_topics_path(training_module) }

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
