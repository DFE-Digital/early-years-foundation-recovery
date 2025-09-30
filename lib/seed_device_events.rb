# :nocov:
# Usage:
#   rails runner lib/seed_device_events.rb

require 'ostruct'

class SeedDeviceEvents
  DEVICE_TYPES = %w[Desktop Mobile Tablet].freeze

  DURATION_PATTERNS = {
    ten_twenty: 10..20,
    twenty_thirty_five: 20..35,
    thirty_five_sixty: 35..60,
    sixty_ninety: 60..90,
  }.freeze

  def initialize
    @users_created = 0
    @events_created = 0
    @visits_created = 0
  end

  def call
    puts "\nSeeding device engagement events..."

    begin
      @modules = Training::Module.ordered.reject(&:draft?)
    rescue StandardError => e
      puts "\nError fetching modules from Contentful: #{e.message}"
      puts "\nUsing fallback test modules instead..."
      @modules = fallback_modules
    end

    if @modules.empty?
      puts "\nNo modules found. Using fallback test modules..."
      @modules = fallback_modules
    end

    puts "Found #{@modules.count} modules to seed"

    # Clear existing test data (this should be reworked to be a global teardown)
    # clear_existing_data

    create_varied_engagement_patterns

    puts "\nSeeding complete!"
    puts "   Users created: #{@users_created}"
    puts "   Visits created: #{@visits_created}"
    puts "   Events created: #{@events_created}"
  end

private

  def fallback_modules
    [
      OpenStruct.new(name: 'alpha'),
      OpenStruct.new(name: 'bravo'),
      OpenStruct.new(name: 'charlie'),
    ]
  end

  def create_varied_engagement_patterns
    @modules.each do |mod|
      puts "\nModule: #{mod.name}"

      create_device_cohort(mod, 'Desktop', completers: 15, non_completers: 3)

      create_device_cohort(mod, 'Mobile', completers: 8, non_completers: 5)

      create_device_cohort(mod, 'Tablet', completers: 6, non_completers: 2)
    end
  end

  def create_device_cohort(mod, device_type, completers:, non_completers:)
    completers.times do |i|
      user = create_user("#{device_type.downcase}_completer_#{mod.name}_#{i}")
      duration_pattern = select_duration_pattern(device_type)
      create_complete_journey(user, mod, device_type, duration_pattern)
    end

    non_completers.times do |i|
      user = create_user("#{device_type.downcase}_dropout_#{mod.name}_#{i}")
      create_incomplete_journey(user, mod, device_type)
    end

    print "  #{device_type}: #{completers} completed, #{non_completers} dropped off"
  end

  def create_complete_journey(user, mod, device_type, duration_pattern)
    visit = create_visit(user, device_type)

    duration_minutes = rand(duration_pattern)

    base_time = random_past_time
    start_time = base_time
    complete_time = base_time + duration_minutes.minutes

    create_event(
      user: user,
      visit: visit,
      name: 'module_start',
      module_name: mod.name,
      time: start_time,
    )

    create_event(
      user: user,
      visit: visit,
      name: 'module_complete',
      module_name: mod.name,
      time: complete_time,
    )
  end

  def create_incomplete_journey(user, mod, device_type)
    visit = create_visit(user, device_type)

    create_event(
      user: user,
      visit: visit,
      name: 'module_start',
      module_name: mod.name,
      time: random_past_time,
    )
  end

  def create_user(email_suffix)
    user = User.create!(
      email: "test_#{email_suffix}@example.gov.uk",
      password: 'Password123!',
      password_confirmation: 'Password123!',
      terms_and_conditions_agreed_at: Time.zone.now,
    )
    @users_created += 1
    user
  end

  def create_visit(user, device_type)
    visit = Visit.create!(
      user_id: user.id,
      device_type: device_type,
      started_at: random_past_time,
      visit_token: SecureRandom.hex(16),
      visitor_token: SecureRandom.hex(16),
    )
    @visits_created += 1
    visit
  end

  def create_event(user:, visit:, name:, module_name:, time:)
    Event.create!(
      user: user,
      visit: visit,
      name: name,
      properties: { training_module_id: module_name },
      time: time,
    )
    @events_created += 1
  end

  def select_duration_pattern(device_type)
    # Mobile users simulated to be faster
    # Desktop users have more varied patterns
    case device_type
    when 'Mobile'
      rand < 0.6 ? DURATION_PATTERNS[:ten_twenty] : DURATION_PATTERNS[:moderate]
    when 'Desktop'
      patterns = %i[ten_twenty twenty_thirty_five thirty_five_sixty sixty_ninety]
      weights = [0.15, 0.40, 0.35, 0.10]
      DURATION_PATTERNS[weighted_sample(patterns, weights)]
    when 'Tablet'
      rand < 0.5 ? DURATION_PATTERNS[:twenty_thirty_five] : DURATION_PATTERNS[:thirty_five_sixty]
    end
  end

  def weighted_sample(items, weights)
    total = weights.sum
    random = rand * total

    items.zip(weights).each do |item, weight|
      random -= weight
      return item if random <= 0
    end

    items.last
  end

  def random_past_time
    rand(90.days.ago..Time.zone.now)
  end

  def clear_existing_data
    puts "\n  Clearing existing test data..."
    Event.where("user_id IN (SELECT id FROM users WHERE email LIKE 'test_%@example.gov.uk')").delete_all
    Visit.where("user_id IN (SELECT id FROM users WHERE email LIKE 'test_%@example.gov.uk')").delete_all
    User.where("email LIKE 'test_%@example.gov.uk'").delete_all
    puts '   Existing test data cleared'
  end
end

# Run the seeder if this file is executed directly
SeedDeviceEvents.new.call if __FILE__ == $PROGRAM_NAME
