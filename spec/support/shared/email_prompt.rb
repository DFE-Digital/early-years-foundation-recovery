RSpec.shared_examples 'an email prompt' do |job_vars, mailer_vars|
  # Context for verifying that the correct users are messaged with the correct template.
  #
  # Before using this shared context, make sure to define the following variables in your spec:
  # - `template`: The email template being sent.
  # - `included`: An array of users who should receive the email.
  # - `excluded`: An array of users who should not receive the email.
  #
  # This context checks if the recipients match `included` and not `excluded`,
  # and if the job uses the specified email `template` correctly.

  it 'messages the correct users' do
    expect(included).to eq described_class.recipients
    expect(excluded).not_to eq described_class.recipients
  end

  it 'uses the correct template' do
    email = instance_double(Mail::Message, deliver: nil)

    described_class.recipients.each do |recipient|
      allow(NotifyMailer).to receive(template).with(recipient, *mailer_vars).and_return(email)
    end

    described_class.run(*job_vars)
  end
end
