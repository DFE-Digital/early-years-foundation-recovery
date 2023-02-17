# frozen_string_literal: true

describe 'Complete modules' do
  include_context 'with user'

  before do
    ui.my_learning.load
  end

  describe 'Child Development and the EYFS' do
    let(:module_name) { 'child-development-and-the-eyfs' }
    it 'has a happy path' do
      overview = ui.my_learning.start_child_development_training
      expect(overview).to be_displayed(module_name: module_name)

      what_to_expect = overview.start_module(module_name)
      expect(what_to_expect).to be_displayed(module_name: module_name, page_name: 'what-to-expect')

      sub_module_intro = what_to_expect.next_page
      expect(sub_module_intro).to be_displayed(module_name: module_name, page_name: '1-1')

      sm1 = sub_module_intro.next_page       
      expect(sm1).to be_displayed(module_name: module_name, page_name: '1-1-1')

      tp1 = sm1.next_page(notes: true)
      expect(tp1).to be_displayed(module_name: module_name, page_name: '1-1-1-1')

      q1 = tp1.next_page(question: true)
      expect(q1).to be_displayed(module_name: module_name, question: '1-1-1-1b')

      a1 = q1.answer_with(response: "A child’s belief that they can succeed")
      expect(a1).to be_displayed(module_name: module_name, question: '1-1-1-1b')

      tp2 = a1.next_page(notes: true)
      expect(tp2).to be_displayed(module_name: module_name, page_name: '1-1-1-2')

      q2 = tp2.next_page(question: true)
      expect(q2).to be_displayed(module_name: module_name, question: '1-1-1-2b')

      a2 = q2.answer_with(response: "The teaching activities you choose")
      expect(a2).to be_displayed(module_name: module_name, question: '1-1-1-2b')

      tp3 = a2.next_page(notes: true)
      expect(tp3).to be_displayed(module_name: module_name, page_name: '1-1-1-3')

      tp4 = tp3.next_page(notes: true)
      expect(tp4).to be_displayed(module_name: module_name, page_name: '1-1-1-4')

      q3 = tp4.next_page(question: true)
      expect(q3).to be_displayed(module_name: module_name, question: '1-1-1-4b')

      a3 = q3.answer_with(response: "True")
      expect(a3).to be_displayed(module_name: module_name, question: '1-1-1-4b')

      tp5 = a3.next_page(notes: true)
      expect(tp5).to be_displayed(module_name: module_name, page_name: '1-1-1-5')

      tp6 = tp5.next_page
      expect(tp6).to be_displayed(module_name: module_name, page_name: '1-1-1-6')

      q4 = tp6.next_page(question: true)
      expect(q4).to be_displayed(module_name: module_name, question: '1-1-1-6b')
      
      a4 = q4.answers_with(response: ["Communication issues","Inconsistency","Unsuitable activities or experiences"])
      expect(a4).to be_displayed(module_name: module_name, question: '1-1-1-6b')

      tp7 = a4.next_page(notes: true)
      expect(tp7).to be_displayed(module_name: module_name, page_name: '1-1-1-7')

      q5 = tp7.next_page(question: true)
      expect(q5).to be_displayed(module_name: module_name, question: '1-1-1-7b')

      a5 = q5.answer_with(response: "Create a new numbers activity that involves the toy cars, for example counting the toy cars as Fatima drives them into the toy garage")
      expect(a5).to be_displayed(module_name: module_name, question: '1-1-1-7b')

      sm2 = a5.next_page
      expect(sm2).to be_displayed(module_name: module_name, page_name: '1-1-2')

      tp21 = sm2.next_page
      expect(tp21).to be_displayed(module_name: module_name, page_name: '1-1-2-1')

      tp22 = tp21.next_page
      expect(tp22).to be_displayed(module_name: module_name, page_name: '1-1-2-2')

      tp23 = tp22.next_page
      expect(tp23).to be_displayed(module_name: module_name, page_name: '1-1-2-3')

      q23 = tp23.next_page(question: true)
      expect(q23).to be_displayed(module_name: module_name, question: '1-1-2-3b')

      a23 = q23.answer_with(response: "Learn and practise new vocabulary" )
      expect(a23).to be_displayed(module_name: module_name, question: '1-1-2-3b')

      tp24 = a23.next_page
      expect(tp24).to be_displayed(module_name: module_name, page_name: '1-1-2-4')

      q24 = tp24.next_page(question: true)
      expect(q24).to be_displayed(module_name: module_name, question: '1-1-2-4b')

      a24 = q24.answer_with(response: "True")
      expect(a24).to be_displayed(module_name: module_name, question: '1-1-2-4b')

      tp25 = a24.next_page
      tp26 = tp25.next_page

      q26 = tp26.next_page(question: true)
      a26 = q26.answers_with(response: ["Copying older siblings during physical activity", "Spending more time outside"])

      tp27 = a26.next_page
      tp28 = tp27.next_page
      tp29 = tp28.next_page(notes: true)
      q29 = tp29.next_page(question: true)
      a29 = q29.answers_with(response: ["Express their individual needs and preferences", "Feel valued and important", "Manage their behaviour"])

      tp210 = a29.next_page
      q210 = tp210.next_page(question: true)
      a210 = q210.answer_with(response: "True")

      sm2 = a210.next_page
      tp21 = sm2.next_page
      tp211 = tp21.next_page(notes: true)
      tp212 = tp211.next_page
      q212 = tp212.next_page(question: true)
      a212 = q212.answer_with(response: "True")
      tp213 = a212.next_page(notes: true)
      tp214 = tp213.next_page(notes: true)
      q214 = tp214.next_page(question: true)
      a214 = q214.answer_with(response: "Access to outdoor environments and activities")
      q214c = a214.next_page(question: true)
      a214c = q214c.answer_with(response: "False")
      tp215 = a214c.next_page(notes: true)
      q215 = tp215.next_page(question: true)
      a215 = q215.answers_with(response: ["Increased social and emotional development", "Increased concentration", "Increased imagination and creativity"])
      tp216 = a215.next_page
      v216 = tp216.next_page
      q216 = v216.next_page(question: true)
      a216 = q216.answer_with(response: "False")
      
      tp22 = a216.next_page
      tp221 = tp22.next_page(notes: true)
      q221 = tp221.next_page(question: true)
      a221 = q221.answers_with(response: ["Positive relationships with parents and carers", "Quality and consistency of care", "Equality of opportunity"])

      tp222 = a221.next_page
      q222 = tp222.next_page(question: true)
      a222 = q222.answer_with(response: "Summative")

      sm3 = a222.next_page
      expect(sm3).to be_displayed(module_name: module_name, page_name: '1-3')
      recap = sm3.next_page
      expect(recap).to be_displayed(module_name: module_name, page_name: '1-3-1')
      eom_test = recap.next_page
      expect(eom_test).to be_displayed(module_name: module_name, page_name: '1-3-4')
      q341 = eom_test.starting_test
      q342 = q341.quiz_answers_with(response: ["Helping children to develop resilience, confidence and self-efficacy", "Supporting children to gain new knowledge", "Helping you plan a curriculum and environment that promotes success for all"])
      q343 = q342.quiz_answer_with(response: "False")
      q344 = q343.quiz_answer_with(response: "Scaffolding")
      q345 = q344.quiz_answers_with(response: ["Encouraging curiosity", "Increasing engagement by using children's interests", "Meeting all the needs of the child"])
      q346 = q345.quiz_answers_with(response: ["Cooking", "Playing with number related apps and games"])
      q347 = q346.quiz_answer_with(response: "Their expressive arts skills")
      q348 = q347.quiz_answer_with(response: "True")
      q349 = q348.quiz_answers_with(response: ["Children's identity and culture", "Children's interests and learning needs", "Children's individual communication needs", "Children's previous experiences"])
      q3410 = q349.quiz_answers_with(response: ["Increasing children’s imagination and creativity", "Increasing children’s independence", "Helping children to navigate social skills like sharing and turn taking"])
      assessment_result = q3410.finish_quiz_answer_with(response: "False")
      reflect = assessment_result.next_page
      c321 = reflect.next_page(question: true)
      c322 = c321.confidence_answer_with(response: "Strongly agree")
      c323 = c322.confidence_answer_with(response: "Strongly agree")
      c324 = c323.confidence_answer_with(response: "Strongly agree")
      c325 = c324.confidence_answer_with(response: "Strongly agree")
      thankyou = c325.finish_confidence_answer_with(response: "Strongly agree")
      expect(thankyou).to be_displayed(module_name: module_name, page_name: '1-3-2-6')

      certificate_page = thankyou.finish_module
      expect(certificate_page).to be_displayed(module_name: module_name, page_name: '1-3-3')
    end
  end

  describe 'Module One  ' do
    it ' Complete all page is displayed Get certificate' do
      expect(ui.my_learning).to be_displayed
      ui.my_learning.module_one_link.click
      ui.modules.complete_module_one
      ui.modules.complete_module_one_test
      # ui.modules.complete_module_one_confidence_check
      # expect(ui.modules).to have_content 'Thank you'
      sleep(2)
      ui.interruption_page.finish_button.click
      sleep(10)
      expect(ui.modules).to have_content 'Get your certificate'
      sleep(10)
      ui.confidence_check.load
      ui.modules.complete_module_one_confidence_check
    end

    describe 'Module two ' do
      it 'Complete all page is displayed get certificate' do
        ui.my_learning.module_two_link.click
        ui.modules.complete_module_two_upto_qs_twenty
        # expect(ui.modules.your_details_success_background.style('background-color')).to eq('background-color' => 'rgb(0, 112, 60)')
        ui.modules.complete_module_two_upto_qs_twenty_one
        # expect(ui.modules.thats_not_quite_right_background.style('background-color')).to eq('background-color' => 'rgb(29, 112, 184)')
        ui.modules.complete_module_two_upto_qs_twenty_two
        expect(ui.modules).to have_content 'End of module test'
        ui.modules.complete_module_two_test
        expect(ui.modules).to have_content 'Congratulations'
        sleep(2)
        ui.interruption_page.next_button.click
        sleep(2)
        expect(ui.modules).to have_content 'Reflect on your learning'
        ui.modules.complete_module_two_confidence_check
        expect(ui.modules).to have_content 'Get your certificate'
        sleep(2)
        ui.modules.go_to_my_modules_button.click
        sleep(10)
      end

      describe 'Module three ' do
        it 'Complete all page is displayed get certificate' do
          ui.my_learning.module_three_link.click
          sleep(30)
          ui.modules.complete_module_three
          ui.modules.complete_module_three_test
          expect(ui.modules).to have_content 'Congratulations'
          sleep(2)
          ui.interruption_page.next_button.click
          sleep(2)
          expect(ui.modules).to have_content 'Reflect on your learning'
          sleep(2)
          ui.modules.complete_module_three_confidence_check
          expect(ui.modules).to have_content 'Get your certificate'
          sleep(10)
        end
      end
    end
  end
end
