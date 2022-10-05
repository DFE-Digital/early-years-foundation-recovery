# frozen_string_literal: true

module Pages
  class Modules < Base
    set_url '/modules/child-development-and-the-eyfs'

    element :next_button, '.govuk-button', text: 'Next'
    element :next_button_1, 'input[type="submit"]'
    element :finish_button, '.govuk-button', text: 'Finish'
    element :go_to_my_learning_button, '.govuk-button', text: 'Go to My Learning'
    element :go_to_my_modules_button, '.govuk-button', text: 'Go to My modules'

    element :start_button_module_one, "a[href='/modules/child-development-and-the-eyfs/content-pages/what-to-expect']"

    # element :start_button_module_one, "a[href='/modules/child-development-and-the-eyfs/content-pages/before-you-start']"
    element :resume_training_button, '.govuk-button', text: 'Resume training'
    element :strongly_agree, '#questionnaire-1-importance-child-development-1-field'
    element :strongly_agree_1, '.govuk-radios__label', text: 'Strongly agree'
    element :your_details_success_background, '.govuk-notification-banner--success'
    element :thats_not_quite_right_background, '.govuk-notification-banner'
    element :agree, '#questionnaire-1-importance-child-development-2-field'
    element :neither_agree_nor_disagree, '#questionnaire-1-importance-child-development-3-field'
    element :disagree, '#questionnaire-1-importance-child-development-4-field'
    element :strongly_disagree, '#questionnaire-1-importance-child-development-5-field'

    # element :start_button_module_two, "a[href='/modules/brain-development-and-how-children-learn/content-pages/before-you-start']"
    element :start_button_module_two, "a[href='/modules/brain-development-and-how-children-learn/content-pages/what-to-expect']"
    element :start_button, 'button.govuk-button', text: 'Start'

    element :a_childs_belief_that_they_can_succeed_radio_button, '.govuk-radios__label', text: 'A child’s belief that they can succeed'
    element :the_teaching_activities_you_choose_radio_button, '.govuk-radios__label', text: 'The teaching activities you choose'

    element :communication_issues_check_box, '.govuk-checkboxes__label', text: 'Communication issues'
    element :inconsistency_check_box, '.govuk-checkboxes__label', text: 'Inconsistency'
    element :unsuitable_activities_or_experiences_check_box, '.govuk-checkboxes__label', text: 'Unsuitable activities or experiences'

    element :express_their_individual_needs_and_preferences_check_box, '.govuk-checkboxes__label', text: 'Express their individual needs and preferences'
    element :feel_valued_and_important_check_box, '.govuk-checkboxes__label', text: 'Feel valued and important'
    element :manage_their_behaviour_check_box, '.govuk-checkboxes__label', text: 'Manage their behaviour'

    element :access_to_outdoor_environments_and_activities_radio_button, '.govuk-radios__label', text: 'Access to outdoor environments and activities'

    element :summative_radio_button, '.govuk-radios__label', text: 'Summative'

    element :create_a_new_numbers_activity_that_involves_the_toy_cars_radio_button, '.govuk-radios__label', text: 'Create a new numbers activity that involves the toy cars'
    element :learn_and_practise_new_vocabulary_radio_button, '.govuk-radios__label', text: 'Learn and practise new vocabulary'

    element :copying_older_siblings_during_physical_activity_check_box, '.govuk-checkboxes__label', text: 'Copying older siblings during physical activity'
    element :spending_more_time_outside_check_box, '.govuk-checkboxes__label', text: 'Spending more time outside'
    element :increased_social_and_emotional_development_check_box, '.govuk-checkboxes__label', text: 'Increased social and emotional development'
    element :increased_concentration_check_box, '.govuk-checkboxes__label', text: 'Increased concentration'
    element :increased_imagination_and_creativity_check_box, '.govuk-checkboxes__label', text: 'Increased imagination and creativity'

    element :positive_relationships_with_parents_and_carers_check_box, '.govuk-checkboxes__label', text: 'Positive relationships with parents and carers'
    element :quality_and_consistency_of_care_check_box, '.govuk-checkboxes__label', text: 'Quality and consistency of care'
    element :equality_of_opportunity_check_box, '.govuk-checkboxes__label', text: 'Equality of opportunity'

    element :helping_children_to_develop_resilience_confidence_and_self_efficacy_check_box, '.govuk-checkboxes__label', text: 'Helping children to develop resilience, confidence and self-efficacy'
    element :supporting_children_to_gain_new_knowledge_check_box_check_box, '.govuk-checkboxes__label', text: 'Supporting children to gain new knowledge'
    element :helping_you_plan_a_curriculum_and_environment_that_promotes_success_for_all_check_box, '.govuk-checkboxes__label', text: 'Helping you plan a curriculum and environment that promotes success for all'

    element :encouraging_curiosity_check_box, '.govuk-checkboxes__label', text: 'Encouraging curiosity'
    element :increasing_engagement_by_using_childrens_interests_check_box, '.govuk-checkboxes__label', text: 'Increasing engagement by using children\'s interests'
    element :meeting_all_the_needs_of_the_child_check_box, '.govuk-checkboxes__label', text: 'Meeting all the needs of the child'

    element :cooking_check_box, '.govuk-checkboxes__label', text: 'Cooking'
    element :playing_with_number_related_apps_and_games_check_box, '.govuk-checkboxes__label', text: 'Playing with number related apps and games'

    element :their_expressive_arts_skills_radio_button, '.govuk-radios__label', text: 'Their expressive arts skills'

    element :childrens_identity_and_culture_check_box, '.govuk-checkboxes__label', text: 'Children\'s identity and culture'
    element :childrens_interests_and_learning_needs_check_box, '.govuk-checkboxes__label', text: 'Children\'s interests and learning needs'
    element :childrens_individual_communication_needs_check_box, '.govuk-checkboxes__label', text: 'Children\'s individual communication needs'
    element :childrens_previous_experiences_check_box, '.govuk-checkboxes__label', text: 'Children\'s previous experiences'

    element :increasing_childrens_imagination_and_creativity_check_box, '.govuk-checkboxes__label', text: 'Increasing children’s imagination and creativity'
    element :increasing_childrens_independence_check_box, '.govuk-checkboxes__label', text: 'Increasing children’s independence'
    element :helping_children_to_navigate_social_skills_like_sharing_and_turn_taking_check_box, '.govuk-checkboxes__label', text: 'Helping children to navigate social skills like sharing and turn taking'

    element :cerebellum_radio_button, '.govuk-radios__label', text: 'Cerebellum'
    element :trimester_three_radio_button, '.govuk-radios__label', text: 'Trimester 3'
    element :smoking_radio_button, '.govuk-radios__label', text: 'Smoking'
    element :mothers_diet_radio_button, '.govuk-radios__label', text: 'The mother\'s diet during pregnancy'
    element :improved_sight_check_box, '.govuk-checkboxes__label', text: 'Improved sight'
    element :reduced_stress_check_box, '.govuk-checkboxes__label', text: 'Reduced stress'
    element :sensorimotor_stage_radio_button, '.govuk-radios__label', text: 'Sensorimotor stage'

    element :supportive_environment_check_box, '.govuk-checkboxes__label', text: 'The importance of a supportive environment'
    element :social_interaction_peer_teaching_check_box, '.govuk-checkboxes__label', text: 'Promotion of social interaction and peer teaching'
    element :inconsistencies_in_thoughts_check_box, '.govuk-checkboxes__label', text: 'Opportunities to test inconsistencies in thoughts'
    element :fixed_intellectual_ability_check_box, '.govuk-checkboxes__label', text: 'Fixed intellectual ability'

    element :forming_abstract_thoughts_check_box, '.govuk-checkboxes__label', text: 'Forming abstract thoughts'
    element :making_meaningful_relationships_check_box, '.govuk-checkboxes__label', text: 'Making meaningful relationships'
    element :socio_economic_factors_check_box, '.govuk-checkboxes__label', text: 'Socio-economic factors'
    element :sensorimotor_actions_check_box, '.govuk-checkboxes__label', text: 'Sensorimotor actions'

    element :explore_and_learn_radio_button, '.govuk-radios__label', text: 'Explore and learn'
    element :support_rapid_development_radio_button, '.govuk-radios__label', text: 'Support rapid development'
    element :true_radio_button, '.govuk-radios__label', text: 'True'
    element :false_radio_button, '.govuk-radios__label', text: 'False'
    element :lower_level_than_their_expected_radio_button, '.govuk-radios__label', text: 'When a child is at a lower level than their expected milestone'

    element :observation_checkpoints_check_box, '.govuk-checkboxes__label', text: 'Observation checkpoints'
    element :an_enabling_environment_check_box, '.govuk-checkboxes__label', text: 'An enabling environment'
    element :child_development_knowledge_check_box, '.govuk-checkboxes__label', text: 'Child development knowledge'
    element :high_quality_practitioner_interactions_check_box, '.govuk-checkboxes__label', text: 'High quality practitioner interactions'
    element :physiological_radio_button, '.govuk-radios__label', text: 'Physiological'
    element :self_esteem_radio_button, '.govuk-checkboxes__label', text: 'Self-esteem'

    element :four_radio_button, '.govuk-radios__label', text: '4'
    element :iconic_radio_button, '.govuk-radios__label', text: 'Iconic'
    element :scaffolding_radio_button, '.govuk-radios__label', text: 'Scaffolding'

    element :three_radio_button, '.govuk-radios__label', text: '3'

    element :increased_engagement_check_box, '.govuk-checkboxes__label', text: 'Increased engagement'
    element :busier_lifestyles_check_box, '.govuk-checkboxes__label', text: 'Busier lifestyles'
    element :increased_access_to_technology_check_box, '.govuk-checkboxes__label', text: 'Increased access to technology'
    element :imposed_lockdowns_check_box, '.govuk-checkboxes__label', text: 'Imposed lockdowns'

    element :preparing_food_check_box, '.govuk-checkboxes__label', text: 'Preparing food'
    element :limiting_food_options_check_box, '.govuk-checkboxes__label', text: 'Limiting food options'
    element :laying_the_table_check_box, '.govuk-checkboxes__label', text: 'Laying the table'
    element :allowing_children_to_serve_themselves_check_box, '.govuk-checkboxes__label', text: 'Allowing children to serve themselves'

    element :parent_to_parent_check_box, '.govuk-checkboxes__label', text: 'Parent to parent'
    element :practitioner_to_practitioner_check_box, '.govuk-checkboxes__label', text: 'Practitioner to practitioner'
    element :practitioner_to_parent_check_box, '.govuk-checkboxes__label', text: 'Practitioner to parent'

    element :start_test_button, '.govuk-button', text: 'Start test'

    element :occipital_lobes_radio_button, '.govuk-radios__label', text: 'Occipital lobes'
    element :save_and_continue, 'button.govuk-button'

    element :social_isolation_radio_button, '.govuk-radios__label', text: 'Social isolation'

    element :save_and_continue_button, 'input[type="submit"]'
    element :finish_test_button, 'input[type="submit"]'

    element :mental_health_issues_check_box, '.govuk-checkboxes__label', text: 'Mental health issues'
    element :lower_academic_success_check_box, '.govuk-checkboxes__label', text: 'Lower academic success'

    element :planning_to_meet_individual_needs_check_box, '.govuk-checkboxes__label', text: 'Planning to meet individual needs'
    element :using_observation_checkpoints_check_box, '.govuk-checkboxes__label', text: 'Using observation checkpoints'
    element :praise_them_more_check_box, '.govuk-checkboxes__label', text: 'Praise them more'
    element :recording_and_reporting_check_box, '.govuk-checkboxes__label', text: "Recording and reporting any concerns in line with your setting's requirements"

    element :neurological_disorders_check_box, '.govuk-checkboxes__label', text: 'Neurological disorders'
    element :abuse_check_box, '.govuk-checkboxes__label', text: 'Abuse'
    element :accidents_check_box, '.govuk-checkboxes__label', text: 'Accidents'

    element :vygotsky_check_box, '.govuk-checkboxes__label', text: 'Vygotsky'
    element :bruner_check_box, '.govuk-checkboxes__label', text: 'Bruner'

    element :modelling_check_box, '.govuk-checkboxes__label', text: 'Modelling'
    element :using_visual_aids_check_box, '.govuk-checkboxes__label', text: 'Using visual aids'
    element :providing_examples_check_box, '.govuk-checkboxes__label', text: 'Providing examples'

    element :increased_vocabulary_check_box, '.govuk-checkboxes__label', text: 'Increased vocabulary'
    element :increased_child_participation_check_box, '.govuk-checkboxes__label', text: 'Increased child participation'

    # element :start_button_module_three, "a[href='/modules/personal-social-and-emotional-development/content-pages/before-you-start']"
    element :start_button_module_three, "a[href='/modules/personal-social-and-emotional-development/content-pages/what-to-expect']"
    element :they_have_positive_emotional_responses_radio_button, '.govuk-radios__label', text: 'They have positive emotional responses'
    element :they_believe_they_can_succeed_radio_button, '.govuk-radios__label', text: 'They believe they can succeed'
    element :it_will_encourage_self_worth_in_children_radio_button, '.govuk-radios__label', text: 'It will encourage self-worth in children'
    element :wait_to_see_how_benjamin_reacts_radio_button, '.govuk-radios__label', text: 'Wait to see how Benjamin reacts'
    element :intervene_radio_button, '.govuk-radios__label', text: 'Intervene'
    element :overstimulation_radio_button, '.govuk-radios__label', text: 'Overstimulation'
    element :eighteen_to_thirtysix_months_radio_button, '.govuk-radios__label', text: '18 to 36 months'
    element :the_strange_situation_radio_button, '.govuk-radios__label', text: 'The Strange Situation'
    element :the_child_shares_their_successes_with_you_radio_button, '.govuk-radios__label', text: 'The child shares their successes with you'
    element :insecure_avoidant_attachment_radio_button, '.govuk-radios__label', text: 'Insecure avoidant attachment'
    element :communication_radio_button, '.govuk-radios__label', text: 'Communication'
    element :they_can_become_overwhelmed_radio_button, '.govuk-radios__label', text: 'They can become overwhelmed'

    element :two_radio_button, '.govuk-radios__label', text: '2'
    element :how_important_and_valued_a_child_feels_radio_button, '.govuk-radios__label', text: 'How important and valued a child feels'

    element :routines_check_box, '.govuk-checkboxes__label', text: 'Routines'
    element :relationships_check_box, '.govuk-checkboxes__label', text: 'Relationships'
    element :rules_check_box, '.govuk-checkboxes__label', text: 'Rules'

    element :realistic_radio_button, '.govuk-radios__label', text: 'Realistic expectations'

    element :their_resilience_check_box, '.govuk-checkboxes__label', text: 'Their resilience'
    element :their_self_efficacy_check_box, '.govuk-checkboxes__label', text: 'Their self-efficacy'
    element :weight_bearing_activities_radio_button, '.govuk-radios__label', text: 'Weight bearing activities'
    element :twelve_to_eighteen_months_radio_button, '.govuk-radios__label', text: '12 to 18 months'

    def complete_module_one
      sleep(5)
      start_button_module_one.click
      sleep(10)
      # resume_training_button.click
      next_button.click
      sleep(2)
      # [x] 1st:  what-to-expect
      next_button.click
      sleep(2)
      # [x] 2nd:  before-you-start
      next_button.click
      sleep(2)
      # [x] 3rd:  intro
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      # [_] 4th:  1-1 (submodule 1) Page 0 of 29
      save_and_continue_button.click
      sleep(2)
      a_childs_belief_that_they_can_succeed_radio_button.click
      sleep(2)
      # [_] 5th:  1-1-1 (submodule 1 / topic 1.0) Page 1 of 29
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      # [_] 6th:  1-1-1-1 (submodule 1 / topic 1.1) Page 2 of 29
      save_and_continue_button.click
      sleep(2)
      the_teaching_activities_you_choose_radio_button.click
      # [_] 7th:  1-1-1-1b (submodule 1 / topic 1.1b) Page 3 of 29
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      next_button.click
      sleep(2)
      communication_issues_check_box.click
      inconsistency_check_box.click
      unsuitable_activities_or_experiences_check_box.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      create_a_new_numbers_activity_that_involves_the_toy_cars_radio_button.click
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
      learn_and_practise_new_vocabulary_radio_button.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(90)
      next_button.click
      sleep(2)
      copying_older_siblings_during_physical_activity_check_box.click
      spending_more_time_outside_check_box.click
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
      save_and_continue_button.click
      sleep(2)
      express_their_individual_needs_and_preferences_check_box.click
      feel_valued_and_important_check_box.click
      manage_their_behaviour_check_box.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
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
      save_and_continue_button.click
      sleep(2)
      next_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      access_to_outdoor_environments_and_activities_radio_button.click
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
      save_and_continue_button.click
      sleep(2)
      increased_social_and_emotional_development_check_box.click
      increased_concentration_check_box.click
      increased_imagination_and_creativity_check_box.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
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
      save_and_continue_button.click
      sleep(2)
      positive_relationships_with_parents_and_carers_check_box.click
      quality_and_consistency_of_care_check_box.click
      equality_of_opportunity_check_box.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      summative_radio_button.click
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
      next_button.click
      sleep(2)
    end

    def complete_module_one_test
      sleep(2)
      start_test_button.click
      sleep(2)
      helping_children_to_develop_resilience_confidence_and_self_efficacy_check_box.click
      supporting_children_to_gain_new_knowledge_check_box_check_box.click
      helping_you_plan_a_curriculum_and_environment_that_promotes_success_for_all_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      false_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      scaffolding_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(4)
      encouraging_curiosity_check_box.click
      increasing_engagement_by_using_childrens_interests_check_box.click
      meeting_all_the_needs_of_the_child_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      cooking_check_box.click
      playing_with_number_related_apps_and_games_check_box.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      their_expressive_arts_skills_radio_button.click
      save_and_continue_button.click
      sleep(2)
      true_radio_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      childrens_identity_and_culture_check_box.click
      childrens_interests_and_learning_needs_check_box.click
      childrens_individual_communication_needs_check_box.click
      childrens_previous_experiences_check_box.click
      save_and_continue_button.click
      sleep(2)
      increasing_childrens_imagination_and_creativity_check_box.click
      increasing_childrens_independence_check_box.click
      helping_children_to_navigate_social_skills_like_sharing_and_turn_taking_check_box.click
      save_and_continue_button.click
      sleep(2)
      false_radio_button.click
      sleep(2)
      finish_test_button.click
      sleep(5)
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
      # resume_training_button.click
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
      # resume_training_button.click
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
      save_and_continue_button.click
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
      save_and_continue_button.click
      sleep(2)
      four_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
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
      save_and_continue_button.click
      sleep(2)
      next_button.click
      sleep(3)
      next_button.click
      sleep(3)
      save_and_continue_button.click
      sleep(2)
      save_and_continue_button.click
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
      save_and_continue_button.click
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
      save_and_continue_button.click
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
      save_and_continue_button.click
      sleep(2)
      save_and_continue_button.click
      sleep(2)
      communication_radio_button.click
      sleep(2)
      next_button_1.click
      sleep(2)
      next_button.click
      sleep(2)
      save_and_continue_button.click
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
      save_and_continue_button.click
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
