RSpec.shared_context 'with analytics tasks' do
  include_context 'with events'
  include_context 'with user assessment'
  include_context 'with user answer'

  let(:directory) { 'analytics_files' }
  let(:users_assessments) { UserAssessment.all }
  let(:upload_users_assessments) { described_class.new(bucket_name: 'tests', folder_path: 'userassessments', result_set: users_assessments, file_name: 'user_assessments') }
  let(:user) { create(:user, :registered) }
  let(:user1) { create(:user, :registered) }

  before do
    WebMock.disable_net_connect!
    stub_request(:post, 'https://oauth2.googleapis.com/token').to_return(status: 200, body: '{}', headers: { "Content-Type": 'application/json' })

    # stub request matching anything after name parameter
    #  example: "https://storage.googleapis.com/upload/storage/v1/b/tests/o?name=userassessments/user_assessments2022-12-07T17:23:20Z.csv&uploadType=resumable"
    # stub_request(:post, /https:\/\/storage.googleapis.com\/upload\/storage\/v1\/b\/tests\/o\?name(.+)/).to_return(status: 200, body: "", headers: {})
    # stub_request(:put, "http://nil-uri-given/").to_return(status: 200, body: "", headers: {})

    stub_request(:any, /https:\/\/storage.googleapis.com\/(.+)/).to_return(->(request) do { body: request.body } end)

    # need to investigate this as storage.googleapis.com must return a uri to put file content when streaming data, so need to match that rather than "http://nil-uri-given/"
    # but for now its not the response were testing its the sql and active record payload
    # if code or database changes, we should get an error here.
    stub_request(:put, 'http://nil-uri-given/').to_return(status: 200, body: '', headers: { "Content-Type": 'application/json' })
    Dir.mkdir directory unless File.exist?(directory)
    create_event(user, 'summative_assessment_start', Time.zone.local(2000, 0o1, 0o2), 'brain-development-and-how-children-learn', 'intro')
    create_event(user1, 'confidence_check_complete', Time.zone.local(2000, 0o1, 0o1), 'child-development-and-the-eyfs', 'intro')
    create_user_assessment(user, 10, 'failed', 'brain-development-and-how-children-learn', 'summative_assessment', 'false')
    create_user_answer(user, 10, 'alpha_summative_question_one', [1, 2].freeze, true, 'alpha', '1-3-2-1', 'summative_assessment', nil)
  end

  after do
    FileUtils.rm_rf('analytics_files')
    WebMock.allow_net_connect!
  end
end
