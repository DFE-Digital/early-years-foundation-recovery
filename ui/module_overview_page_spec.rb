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

      tp1 = sub_module_intro.next_page       
      expect(tp1).to be_displayed(module_name: module_name, page_name: '1-1-1')

      tp2 = tp1.next_page(notes: true)
      expect(tp2).to be_displayed(module_name: module_name, page_name: '1-1-1-1')

      q1 = tp2.next_page(question: true)
      expect(q1).to be_displayed(module_name: module_name, question: '1-1-1-1b')

      a1 = q1.answer_with(answer: "A child’s belief that they can succeed")
      expect(a1).to be_displayed(module_name: module_name, question: '1-1-1-1b')

      tp3 = a1.next_page(notes: true)
      expect(tp3).to be_displayed(module_name: module_name, page_name: '1-1-1-2')

      q2 = tp3.next_page(question: true)
      expect(q2).to be_displayed(module_name: module_name, question: '1-1-1-2b')

      a2 = q2.answer_with(answer: "The teaching activities you choose")
      expect(a2).to be_displayed(module_name: module_name, question: '1-1-1-2b')

      tp4 = a2.next_page(notes: true)
      expect(tp4).to be_displayed(module_name: module_name, page_name: '1-1-1-3')

      tp5 = tp4.next_page(notes: true)
      expect(tp5).to be_displayed(module_name: module_name, page_name: '1-1-1-4')

      q3 = tp5.next_page(question: true)
      expect(q3).to be_displayed(module_name: module_name, page_name: '1-1-1-4b')

      a3 = q3.answer_with(answer: "True")
      expect(a3).to be_displayed(module_name: module_name, page_name: '1-1-1-4b')

      tp6 = a3.next_page(notes: true)
      expect(tp6).to be_displayed(module_name: module_name, page_name: '1-1-1-5')
      
      tp7 = tp6.next_page
      expect(tp7).to be_displayed(module_name: module_name, page_name: '1-1-1-6')

      q4 = tp7.next_page(question: true)
      expect(q4).to be_displayed(module_name: module_name, question: '1-1-1-6b')

      a4 = q4.answers_with([2,3,4])
      expect(a4).to be_displayed(module_name: module_name, question: '1-1-1-6b')
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
