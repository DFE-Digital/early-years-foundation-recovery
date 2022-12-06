require 'rails_helper'
require 'fileutils'
Rails.application.load_tasks

# test in this spec are testing for sql issues arising if database structure is changed
# if test fail please check the /lib/tasks/analytics.rake file and test the relevant rake task

RSpec.describe AnalyticsBuild do
  include_context 'with events'
  include_context 'with user assessment'
  include_context 'with user answer'

  let(:directory) { 'analytics_files' }
  let(:user) { create(:user, :registered) }
  let(:user1) { create(:user, :registered) }

  before do
    Dir.mkdir directory unless File.exist?(directory)
    create_event(user, 'module_content_page', Time.zone.local(2000, 0o1, 0o2), 'brain-development-and-how-children-learn', 'intro')
    create_event(user1, 'module_content_page', Time.zone.local(2000, 0o1, 0o1), 'child-development-and-the-eyfs', 'intro')
    create_user_assessment(user, 10, 'failed', 'brain-development-and-how-children-learn', 'summative_assessment', 'false')
    create_user_answer(user, 10, 'alpha_summative_question_one', [1, 2].freeze, true, 'alpha', '1-3-2-1', 'summative_assessment', nil)
  end

  after do
    FileUtils.rm_rf('analytics_files')
  end

  it 'create csv file ahoy visits' do
    Rake::Task['db:analytics:ahoy_visits'].invoke
    files = Dir["#{directory}/ahoy_visits*.csv"]
    expect(files.length).to be > 0
  end

  it 'create csv file users' do
    Rake::Task['db:analytics:users'].invoke
    files = Dir["#{directory}/users*.csv"]
    expect(files.length).to be > 0
  end

  it 'create csv file ahoy events' do
    Rake::Task['db:analytics:ahoy_events'].invoke
    files = Dir["#{directory}/ahoy_events*.csv"]
    expect(files.length).to be > 0
  end

  it 'create csv file user assessments' do
    Rake::Task['db:analytics:user_assessments'].invoke
    files = Dir["#{directory}/user_assessments*.csv"]
    expect(files.length).to be > 0
  end

  it 'create csv file user answers' do
    Rake::Task['db:analytics:user_answers'].invoke
    files = Dir["#{directory}/user_answers*.csv"]
    expect(files.length).to be > 0
  end
end
