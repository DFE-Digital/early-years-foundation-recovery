# frozen_string_literal: true
require_relative './spec_helper'

describe 'Complete modules' do
    include_context 'with user'

    before do
      ui.my_learning.load
    end

    describe 'Module One  ' do
      it ' Complete all page is displayed Get certificate' do
        expect(ui.my_learning).to be_displayed
        ui.my_learning.module_one_link.click
        sleep(10)
        ui.modules.complete_module_one
        ui.modules.complete_module_one_confidence_check
        expect(ui.modules).to have_content 'Thank you'
        sleep(2)
        ui.interruption_page.finish_button.click
        sleep(10)
        expect(ui.modules).to have_content 'Get your certificate'
        sleep(10)
      end

      describe 'Module two ' do
        it 'Complete all page is displayed get certificate' do
          ui.my_learning.module_two_link.click
          ui.modules.complete_module_two_upto_qs_twenty
          expect(ui.modules.your_details_success_background.style('background-color')).to eq('background-color' => 'rgba(0, 112, 60, 1)')
          ui.modules.complete_module_two_upto_qs_twenty_one
          expect(ui.modules.thats_not_quite_right_background.style('background-color')).to eq('background-color' => 'rgba(29, 112, 184, 1)')
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
          ui.modules.go_to_my_learning_button.click
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


