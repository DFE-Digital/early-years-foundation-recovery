require 'rails_helper'
require 'fileutils'
Rails.application.load_tasks

# test in this spec are testing for sql issues arising if database structure is changed
# if test fail please check the /lib/tasks/analytics.rake file and test the relevant rake task

RSpec.describe AnalyticsBuild do
  include_context 'with analytics tasks'

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

  it 'transform dash to underscore' do
    expect(described_class.transform_json_key('tests-json-string')).to match('tests_json_string')
  end

  it 'change json properties id to avoid conflict with primary keys' do
    expect(described_class.change_id('test_key', 'id')).to match('test_key_id')
  end

  it 'build sql for jsonb fields in database' do
    json_column = { "module-4": 570_627, "child-development-and-the-eyfs": 421_725 }
    expect(described_class.build_json_sql('module_time_to_completion', json_column)).to match("COALESCE(module_time_to_completion->>'module-4', 'null') AS module_4,COALESCE(module_time_to_completion->>'child-development-and-the-eyfs', 'null') AS child_development_and_the_eyfs,")
  end

  it 'upload users assessments' do
    expect(upload_users_assessments.upload).to match(nil)
  end

  it 'delete users assessments files' do
    body_response_bucket_files = {
      "kind": 'storage#objects',
      "items": [
        {
          "kind": 'storage#object',
          "id": 'tests/userassessments/userassessments2022-12-15T03:41:44Z.csv/1671075705464312',
          "selfLink": 'https://www.googleapis.com/storage/v1/b/tests/o/userassessments%2Fuserassessments2022-12-15T03:41:44Z.csv',
          "mediaLink": 'https://storage.googleapis.com/download/storage/v1/b/tests/o/userassessments%2Fuserassessments2022-12-15T03:41:44Z.csv?generation=1671075705464312&alt=media',
          "name": 'userassessments/userassessments2022-12-15T03:41:44Z.csv',
          "bucket": 'tests',
        },
      ],
    }

    stub_request(:get, 'https://storage.googleapis.com/storage/v1/b/tests/o?prefix=userassessments').to_return(status: 200, body: body_response_bucket_files.to_json, headers: { "Content-Type": 'application/json' })
    expect(upload_users_assessments.delete_files).to match(Array)
  end
end
