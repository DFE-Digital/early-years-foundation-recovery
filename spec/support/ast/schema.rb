require 'content_test_schema'

# TODO: remove need to wrap "fill_in" kwargs
def input_text(field, input)
  fill_in field, with: input
end
