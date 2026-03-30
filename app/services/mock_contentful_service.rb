# frozen_string_literal: true

# MockContentfulService mimics the interface of the real Contentful service but returns static data.
# Use this in unit tests to avoid any network or ENV dependency.
class MockContentfulService
  # Example method: returns a mock page object
  def fetch_page(slug)
    OpenStruct.new(
      title: "Test Page for #{slug}",
      body: "This is mock content for #{slug}.",
      updated_at: Time.now
    )
  end

  # Add more methods as needed to match your real Contentful service interface
end
