# frozen_string_literal: true

module Pages
  class Modules < Base
    set_url '/modules/child-development-and-the-eyfs'

    element :next_button, '.govuk-button', text: 'Next'
    element :next_button_1,'input[type="submit"]'
    element :finish_button, '.govuk-button', text: 'Finish'
    element :go_to_my_learning_button, '.govuk-button', text: 'Go to My Learning'

    element :start_button_module_one, "a[href='/modules/child-development-and-the-eyfs/content-pages/what-to-expect']"

    #element :start_button_module_one, "a[href='/modules/child-development-and-the-eyfs/content-pages/before-you-start']"
    element :resume_training_button, '.govuk-button', text: 'Resume training'
    element :strongly_agree, '#questionnaire-1-importance-child-development-1-field'
    element :strongly_agree_1, '.govuk-radios__label', text: 'Strongly agree'
    element :your_details_success_background, '.govuk-notification-banner--success'
    element :thats_not_quite_right_background, '.govuk-notification-banner'
    element :agree, '#questionnaire-1-importance-child-development-2-field'
    element :neither_agree_nor_disagree, '#questionnaire-1-importance-child-development-3-field'
    element :disagree, '#questionnaire-1-importance-child-development-4-field'
    element :strongly_disagree, '#questionnaire-1-importance-child-development-5-field'

    element :start_button_module_two, "a[href='/modules/brain-development-and-how-children-learn/content-pages/before-you-start']"
    element :start_button, 'button.govuk-button', text: 'Start'

    element :cerebellum_radio_button, '.govuk-radios__label', text: 'Cerebellum'
    element :trimester_three_radio_button, '.govuk-radios__label', text: 'Trimester 3'
    element :smoking_radio_button,'.govuk-radios__label', text: 'Smoking'
    element :mothers_diet_radio_button,'.govuk-radios__label', text: "The mother's diet during pregnancy"
    element :improved_sight_check_box, '.govuk-checkboxes__label', text:'Improved sight'
    element :reduced_stress_check_box, '.govuk-checkboxes__label', text:'Reduced stress'
    element :sensorimotor_stage_radio_button,'.govuk-radios__label', text: 'Sensorimotor stage'

    element :supportive_environment_check_box, '.govuk-checkboxes__label', text:'The importance of a supportive environment'
    element :social_interaction_peer_teaching_check_box, '.govuk-checkboxes__label', text:'Promotion of social interaction and peer teaching'
    element :inconsistencies_in_thoughts_check_box, '.govuk-checkboxes__label', text:'Opportunities to test inconsistencies in thoughts'
    element :fixed_intellectual_ability_check_box, '.govuk-checkboxes__label', text:'Fixed intellectual ability'

    element :forming_abstract_thoughts_check_box, '.govuk-checkboxes__label', text:'Forming abstract thoughts'
    element :making_meaningful_relationships_check_box, '.govuk-checkboxes__label', text:'Making meaningful relationships'
    element :socio_economic_factors_check_box, '.govuk-checkboxes__label', text:'Socio-economic factors'
    element :sensorimotor_actions_check_box, '.govuk-checkboxes__label', text:'Sensorimotor actions'

    element :explore_and_learn_radio_button,'.govuk-radios__label', text: 'Explore and learn'
    element :support_rapid_development_radio_button, '.govuk-radios__label', text: 'Support rapid development'
    element :true_radio_button, '.govuk-radios__label', text: 'True'
    element :false_radio_button, '.govuk-radios__label', text: 'False'
    element :lower_level_than_their_expected_radio_button, '.govuk-radios__label', text: 'When a child is at a lower level than their expected milestone'

    element :observation_checkpoints_check_box, '.govuk-checkboxes__label', text: 'Observation checkpoints'
    element :an_enabling_environment_check_box, '.govuk-checkboxes__label', text: 'An enabling environment'
    element :child_development_knowledge_check_box, '.govuk-checkboxes__label', text: 'Child development knowledge'
    element :high_quality_practitioner_interactions_check_box, '.govuk-checkboxes__label', text: 'High quality practitioner interactions'
    element :physiological_radio_button, '.govuk-radios__label', text:'Physiological'
    element :self_esteem_radio_button, '.govuk-checkboxes__label', text:'Self-esteem'

    element :four_radio_button,'.govuk-radios__label', text:'4'
    element :iconic_radio_button, '.govuk-radios__label', text:'Iconic'
    element :scaffolding_radio_button, '.govuk-radios__label', text:'Scaffolding'

    element :three_radio_button,'.govuk-radios__label', text:'3'

    element :increased_engagement_check_box, '.govuk-checkboxes__label', text: 'Increased engagement'
    element :busier_lifestyles_check_box, '.govuk-checkboxes__label', text: 'Busier lifestyles'
    element :increased_access_to_technology_check_box, '.govuk-checkboxes__label', text: 'Increased access to technology'
    element :imposed_lockdowns_check_box, '.govuk-checkboxes__label', text: 'Imposed lockdowns'

    element :preparing_food_check_box, '.govuk-checkboxes__label', text: 'Preparing food'
    element :limiting_food_options_check_box, '.govuk-checkboxes__label', text: 'Limiting food options'
    element :laying_the_table_check_box, '.govuk-checkboxes__label', text: 'Laying the table'
    element :allowing_children_to_serve_themselves_check_box, '.govuk-checkboxes__label', text: 'Allowing children to serve themselves'

    element :parent_to_parent_check_box, '.govuk-checkboxes__label', text: 'Parent to parent'
    element :practitioner_to_practitioner_check_box,'.govuk-checkboxes__label', text: 'Practitioner to practitioner'
    element :practitioner_to_parent_check_box, '.govuk-checkboxes__label', text: 'Practitioner to parent'

    element :start_test_button, '.govuk-button', text: 'Start test'

    element :occipital_lobes_radio_button, '.govuk-radios__label', text:'Occipital lobes'
    element :save_and_continue,'button.govuk-button'

    element :social_isolation_radio_button, '.govuk-radios__label', text:'Social isolation'

    element :save_and_continue_button, 'input[type="submit"]'
    element :finish_test_button, 'input[type="submit"]'

    element :mental_health_issues_check_box,'.govuk-checkboxes__label', text: 'Mental health issues'
    element :lower_academic_success_check_box, '.govuk-checkboxes__label', text: 'Lower academic success'

    element :planning_to_meet_individual_needs_check_box,'.govuk-checkboxes__label', text: 'Planning to meet individual needs'
    element :using_observation_checkpoints_check_box, '.govuk-checkboxes__label', text: 'Using observation checkpoints'
    element :praise_them_more_check_box,'.govuk-checkboxes__label', text: 'Praise them more'
    element :recording_and_reporting_check_box, '.govuk-checkboxes__label', text: "Recording and reporting any concerns in line with your setting's requirements"

    element :neurological_disorders_check_box,'.govuk-checkboxes__label', text: 'Neurological disorders'
    element :abuse_check_box, '.govuk-checkboxes__label', text: 'Abuse'
    element :accidents_check_box,'.govuk-checkboxes__label', text: 'Accidents'

    element :vygotsky_check_box, '.govuk-checkboxes__label', text: 'Vygotsky'
    element :bruner_check_box,'.govuk-checkboxes__label', text: 'Bruner'

    element :modelling_check_box,'.govuk-checkboxes__label', text: 'Modelling'
    element :using_visual_aids_check_box,'.govuk-checkboxes__label', text: 'Using visual aids'
    element :providing_examples_check_box,'.govuk-checkboxes__label', text: 'Providing examples'

    element :increased_vocabulary_check_box,'.govuk-checkboxes__label', text: 'Increased vocabulary'
    element :increased_child_participation_check_box,'.govuk-checkboxes__label', text: 'Increased child participation'

    element :start_button_module_three, "a[href='/modules/personal-social-and-emotional-development/content-pages/before-you-start']"
    element :they_have_positive_emotional_responses_radio_button, '.govuk-radios__label', text:'They have positive emotional responses'
    element :they_believe_they_can_succeed_radio_button, '.govuk-radios__label', text:'They believe they can succeed'
    element :it_will_encourage_self_worth_in_children_radio_button, '.govuk-radios__label', text:'It will encourage self-worth in children'
    element :wait_to_see_how_benjamin_reacts_radio_button, '.govuk-radios__label', text:'Wait to see how Benjamin reacts'
    element :intervene_radio_button, '.govuk-radios__label', text:'Intervene'
    element :overstimulation_radio_button, '.govuk-radios__label', text:'Overstimulation'
    element :eighteen_to_thirtysix_months_radio_button, '.govuk-radios__label', text:'18 to 36 months'
    element :the_strange_situation_radio_button, '.govuk-radios__label', text:'The Strange Situation'
    element :the_child_shares_their_successes_with_you_radio_button, '.govuk-radios__label', text:'The child shares their successes with you'
    element :insecure_avoidant_attachment_radio_button, '.govuk-radios__label', text:'Insecure avoidant attachment'
    element :communication_radio_button, '.govuk-radios__label', text:'Communication'
    element :they_can_become_overwhelmed_radio_button, '.govuk-radios__label', text:'They can become overwhelmed'

    element :two_radio_button,'.govuk-radios__label', text:'2'
    element :how_important_and_valued_a_child_feels_radio_button,'.govuk-radios__label', text:'How important and valued a child feels'

    element :routines_check_box,'.govuk-checkboxes__label', text:'Routines'
    element :relationships_check_box,'.govuk-checkboxes__label', text:'Relationships'
    element :rules_check_box,'.govuk-checkboxes__label', text:'Rules'

    element :realistic_radio_button,'.govuk-radios__label', text:'Realistic expectations'

    element :their_resilience_check_box,'.govuk-checkboxes__label', text:'Their resilience'
    element :their_self_efficacy_check_box,'.govuk-checkboxes__label', text:'Their self-efficacy'
    element :weight_bearing_activities_radio_button, '.govuk-radios__label', text:'Weight bearing activities'

    element :twelve_to_eighteen_months_radio_button, '.govuk-radios__label', text:'12 to 18 months'


    def complete_module_one
      sleep(5)
      start_button_module_one.click
      sleep(10)
      #resume_training_button.click
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      #next_button.click
      sleep(10)
    end

    def complete_module_one_confidence_check
      sleep(10)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
    end

    def complete_module_two_upto_qs_twenty
      sleep(10)
      start_button_module_two.click
      #resume_training_button.click
      sleep(10)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      cerebellum_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      trimester_three_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      smoking_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      mothers_diet_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(90)
    end

    def complete_module_two_upto_qs_twenty_one
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      improved_sight_check_box.click
      reduced_stress_check_box.click
      sleep(2)
      next_button_1.click
      sleep(90)
    end


    def complete_module_two_upto_qs_twenty_two
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      sensorimotor_stage_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      supportive_environment_check_box.click
      social_interaction_peer_teaching_check_box.click
      inconsistencies_in_thoughts_check_box.click
      fixed_intellectual_ability_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      forming_abstract_thoughts_check_box.click
      making_meaningful_relationships_check_box.click
      socio_economic_factors_check_box.click
      sensorimotor_actions_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      explore_and_learn_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      support_rapid_development_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      lower_level_than_their_expected_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      observation_checkpoints_check_box.click
      an_enabling_environment_check_box.click
      child_development_knowledge_check_box.click
      high_quality_practitioner_interactions_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      physiological_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(90)
      four_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      iconic_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      scaffolding_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      three_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      busier_lifestyles_check_box.click
      increased_access_to_technology_check_box.click
      imposed_lockdowns_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      preparing_food_check_box.click
      laying_the_table_check_box.click
      allowing_children_to_serve_themselves_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      practitioner_to_practitioner_check_box.click
      practitioner_to_parent_check_box.click
      parent_to_parent_check_box.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(1)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(90)
    end

    def complete_module_two_test
      sleep(2)
      start_test_button.click
      sleep(2)
      occipital_lobes_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      false_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(5)
      social_isolation_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      mental_health_issues_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(180)
      true_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      planning_to_meet_individual_needs_check_box.click
      using_observation_checkpoints_check_box.click
      praise_them_more_check_box.click
      recording_and_reporting_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      neurological_disorders_check_box.click
      abuse_check_box.click
      accidents_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      vygotsky_check_box.click
      bruner_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      modelling_check_box.click
      providing_examples_check_box.click
      using_visual_aids_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      increased_child_participation_check_box.click
      increased_vocabulary_check_box.click
      sleep(2)
      finish_test_button.click
      sleep(5)
    end

    def complete_module_two_confidence_check
      sleep(2)
      next_button.click
      sleep(10)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(10)
      finish_button.click
      sleep(10)
    end

    def complete_module_three
      start_button_module_three.click
      #resume_training_button.click
      sleep(10)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(10)
      four_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      four_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(3)
      they_believe_they_can_succeed_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      it_will_encourage_self_worth_in_children_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      intervene_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      false_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      overstimulation_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      eighteen_to_thirtysix_months_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      the_strange_situation_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      the_child_shares_their_successes_with_you_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      insecure_avoidant_attachment_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      insecure_avoidant_attachment_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      communication_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      they_can_become_overwhelmed_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
    end
    
    def complete_module_three_test
      sleep(2)
      start_test_button.click
      sleep(2)
      two_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(5)
      how_important_and_valued_a_child_feels_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      overstimulation_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      routines_check_box.click
      relationships_check_box.click
      rules_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      three_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      realistic_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      their_resilience_check_box.click
      their_self_efficacy_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      weight_bearing_activities_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      twelve_to_eighteen_months_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      finish_test_button.click
      sleep(5)
    end

    def complete_module_three_confidence_check
      next_button.click
      sleep(10)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(2)
      strongly_agree_1.click
      next_button_1.click
      sleep(10)
      finish_button.click
      sleep(10)
    end
  end
end