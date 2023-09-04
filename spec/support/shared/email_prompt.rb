RSpec.shared_examples 'an email prompt' do |job_vars, mailer_vars|
  #
  # Combine into one?
  it 'messages the correct users' do
    expect(described_class.recipients).to eq included
    expect(described_class.recipients).not_to eq excluded
  end

  it 'uses the correct template' do
    email = instance_double(Mail::Message, deliver: nil)

    described_class.recipients.each do |recipient|
      allow(NotifyMailer).to receive(template).with(recipient, *mailer_vars).and_return(email)
    end

    described_class.run(*job_vars)
  end
end
