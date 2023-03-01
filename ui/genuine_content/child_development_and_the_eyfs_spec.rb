# frozen_string_literal: true

describe 'Walk through' do
  include_context 'with user'

  before do
    ui.my_modules.load
  end

  describe 'Module 1: Child Development and the EYFS' do
    let(:module_name) { 'child-development-and-the-eyfs' }
    let(:module_title) { 'Understanding child development and the EYFS' }

    it 'end to end' do
      overview = ui.my_modules.module_overview(title: module_title, module_name: module_name)
      what_to_expect = overview.start_module
      sub_module_intro = what_to_expect.next_page(module_name: module_name, page_name: '1-1')
      sm1 = sub_module_intro.next_page(module_name: module_name, page_name: '1-1-1')
      tp11 = sm1.next_page(module_name: module_name, page_name: '1-1-1-1')
      _q1 = tp11.next_page(module_name: module_name, question: '1-1-1-1b') # Reflection point
      # a1 = q1.answer_with('A child’s belief that they can succeed', module_name: module_name, question: '1-1-1-1b')
      # tp2 = a1.next_page(module_name: module_name, page_name: '1-1-1-2')
      # q2 = tp2.next_page(module_name: module_name, question: '1-1-1-2b')
      # a2 = q2.answer_with('The teaching activities you choose', module_name: module_name, question: '1-1-1-2b')
      # tp3 = a2.next_page(module_name: module_name, page_name: '1-1-1-3')
      # tp4 = tp3.next_page(module_name: module_name, page_name: '1-1-1-4')
      # q3 = tp4.next_page(module_name: module_name, question: '1-1-1-4b')
      # a3 = q3.answer_with('True', module_name: module_name, question: '1-1-1-4b')
      # tp5 = a3.next_page(module_name: module_name, page_name: '1-1-1-5')
      # tp6 = tp5.next_page(module_name: module_name, page_name: '1-1-1-6')
      # q4 = tp6.next_page(module_name: module_name, question: '1-1-1-6b')
      # a4 = q4.answers_with(
      #   ['Communication issues', 'Inconsistency', 'Unsuitable activities or experiences'],
      #   module_name: module_name,
      #   question: '1-1-1-6b',
      # )
      # tp7 = a4.next_page(module_name: module_name, page_name: '1-1-1-7')
      # q5 = tp7.next_page(module_name: module_name, question: '1-1-1-7b')
      # a5 = q5.answer_with(
      #   'Create a new numbers activity that involves the toy cars, for example counting the toy cars as Fatima drives them into the toy garage',
      #   module_name: module_name,
      #   question: '1-1-1-7b',
      # )
      # sm2 = a5.next_page(module_name: module_name, page_name: '1-1-2')

      # tp21 = sm2.next_page(module_name: module_name, page_name: '1-1-2-1')

      # tp22 = tp21.next_page(module_name: module_name, page_name: '1-1-2-2')

      # tp23 = tp22.next_page(module_name: module_name, page_name: '1-1-2-3')

      # q23 = tp23.next_page(module_name: module_name, question: '1-1-2-3b')

      # a23 = q23.answer_with(
      #   'Learn and practise new vocabulary',
      #   module_name: module_name,
      #   question: '1-1-2-3b',
      # )

      # tp24 = a23.next_page(module_name: module_name, page_name: '1-1-2-4')

      # q24 = tp24.next_page(module_name: module_name, question: '1-1-2-4b')

      # a24 = q24.answer_with(
      #   'True',
      #   module_name: module_name,
      #   question: '1-1-2-4b',
      # )

      # tp25 = a24.next_page(module_name: module_name, page_name: '1-1-2-5')
      # tp26 = tp25.next_page(module_name: module_name, page_name: '1-1-2-6')

      # q26 = tp26.next_page(module_name: module_name, question: '1-1-2-6b')
      # a26 = q26.answers_with(['Copying older siblings during physical activity', 'Spending more time outside'])

      # tp27 = a26.next_page(module_name: module_name, page_name: '1-1-2-7')
      # tp28 = tp27.next_page(module_name: module_name, page_name: '1-1-2-8')
      # tp29 = tp28.next_page(module_name: module_name, page_name: '1-1-2-9')
      # q29 = tp29.next_page(module_name: module_name, question: '1-1-2-9b')
      # a29 = q29.answers_with(['Express their individual needs and preferences', 'Feel valued and important', 'Manage their behaviour'])

      # tp210 = a29.next_page(module_name: module_name, page_name: '1-1-2-10')
      # q210 = tp210.next_page(module_name: module_name, question: '1-1-2-10b')
      # a210 = q210.answer_with('True')

      # sm2 = a210.next_page(module_name: module_name, page_name: '1-2')
      # tp21 = sm2.next_page(module_name: module_name, page_name: '1-2-1')
      # tp211 = tp21.next_page(module_name: module_name, page_name: '1-2-1-1')
      # tp212 = tp211.next_page(module_name: module_name, page_name: '1-2-1-2')
      # q212 = tp212.next_page(module_name: module_name, question: '1-2-1-2b')
      # a212 = q212.answer_with('True')
      # tp213 = a212.next_page(module_name: module_name, page_name: '1-2-1-3')
      # tp214 = tp213.next_page(module_name: module_name, page_name: '1-2-1-4')
      # q214 = tp214.next_page(module_name: module_name, question: '1-2-1-4b')
      # a214 = q214.answer_with('Access to outdoor environments and activities')
      # q214c = a214.next_page(module_name: module_name, question: '1-2-1-4c')
      # a214c = q214c.answer_with('False')
      # tp215 = a214c.next_page(module_name: module_name, page_name: '1-2-1-5')
      # q215 = tp215.next_page(module_name: module_name, question: '1-2-1-5b')
      # a215 = q215.answers_with(['Increased social and emotional development', 'Increased concentration', 'Increased imagination and creativity'])
      # tp216 = a215.next_page(module_name: module_name, page_name: '1-2-1-6')
      # v216 = tp216.next_page(module_name: module_name, page_name: '1-2-1-6video')
      # q216 = v216.next_page(module_name: module_name, question: '1-2-1-6b')
      # a216 = q216.answer_with('False')

      # tp22 = a216.next_page(module_name: module_name, page_name: '1-2-2')
      # tp221 = tp22.next_page(module_name: module_name, page_name: '1-2-2-1')
      # q221 = tp221.next_page(module_name: module_name, question: '1-2-2-1b')
      # a221 = q221.answers_with(['Positive relationships with parents and carers', 'Quality and consistency of care', 'Equality of opportunity'])

      # tp222 = a221.next_page(module_name: module_name, page_name: '1-2-2-2')
      # q222 = tp222.next_page(module_name: module_name, question: '1-2-2-2b')
      # a222 = q222.answer_with('Summative')

      # sm3 = a222.next_page(module_name: module_name, page_name: '1-3')

      # recap = sm3.next_page(module_name: module_name, page_name: '1-3-1')

      # eom_test = recap.next_page(module_name: module_name, page_name: '1-3-4')

      # q341 = eom_test.starting_test
      # q342 = q341.quiz_answers_with(['Helping children to develop resilience, confidence and self-efficacy', 'Supporting children to gain new knowledge', 'Helping you plan a curriculum and environment that promotes success for all'])
      # q343 = q342.quiz_answer_with('False')
      # q344 = q343.quiz_answer_with('Scaffolding')
      # q345 = q344.quiz_answers_with(['Encouraging curiosity', "Increasing engagement by using children's interests", 'Meeting all the needs of the child'])
      # q346 = q345.quiz_answers_with(['Cooking', 'Playing with number related apps and games'])
      # q347 = q346.quiz_answer_with('Their expressive arts skills')
      # q348 = q347.quiz_answer_with('True')
      # q349 = q348.quiz_answers_with(["Children's identity and culture", "Children's interests and learning needs", "Children's individual communication needs", "Children's previous experiences"])
      # q3410 = q349.quiz_answers_with(['Increasing children’s imagination and creativity', 'Increasing children’s independence', 'Helping children to navigate social skills like sharing and turn taking'])
      # assessment_result = q3410.finish_quiz_answer_with('False')
      # reflect = assessment_result.next_page(module_name: module_name, page_name: '1-3-4-11')
      # c321 = reflect.next_page(module_name: module_name, question: '1-3-2-1')
      # c322 = c321.confidence_answer_with('Strongly agree')
      # c323 = c322.confidence_answer_with('Strongly agree')
      # c324 = c323.confidence_answer_with('Strongly agree')
      # c325 = c324.confidence_answer_with('Strongly agree')
      # thankyou = c325.finish_confidence_answer_with('Strongly agree', module_name: module_name, page_name: '1-3-2-6')
      # thankyou.finish_module(module_name: module_name, page_name: '1-3-3')

      ui.home.header.sign_out.click
    end
  end
end
