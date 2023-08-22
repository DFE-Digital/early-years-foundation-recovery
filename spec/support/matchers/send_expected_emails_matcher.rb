RSpec::Matchers.define :send_expected_emails do |mailer_method:, expected_users:, excluded_users:|
  match do |_something|
    @expected_users = expected_users
    @excluded_users = excluded_users
    expected_users.all? { |user| expect(NotifyMailer).to have_received(mailer_method).with(user, any_args).once } &&
      excluded_users.all? { |user| expect(NotifyMailer).not_to have_received(mailer_method).with(user) }
  end

  failure_message do
    "expected to send emails to #{@expected_users} only but it did not"
  end

  description do
    'send emails to the expected users'
  end
end
