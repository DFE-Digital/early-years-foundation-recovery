# https://github.com/ankane/rollup
# https://github.com/ankane/blazer
# https://github.com/ankane/ahoy
#
#
class Ahoy::Store < Ahoy::DatabaseStore
  def visit_model
    Visit
  end

  def event_model
    Event
  end
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

# By default, a new visit is created after 4 hours of inactivity
Ahoy.visit_duration = 4.hours

# By default, a new visitor_token is generated after 2 years
Ahoy.visitor_duration = 2.years
