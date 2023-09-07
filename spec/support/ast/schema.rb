require 'content_test_schema'

# TODO: remove need to wrap "fill_in" kwargs
def make_note(field, input)
  fill_in field, with: input
end
