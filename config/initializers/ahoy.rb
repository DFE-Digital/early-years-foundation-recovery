class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false

# Ensure events are tracked in the test suite
Ahoy.track_bots = Rails.env.test?

# Fidus Pen Test Issue 6.1.7
Ahoy.cookie_options = { httponly: true }
