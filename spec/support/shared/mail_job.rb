RSpec.shared_examples 'a mail job' do
  specify { expect { job }.to output(/#{message}/).to_stdout }
end
