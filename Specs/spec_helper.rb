framework "Cocoa"

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "Classes")


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{ENV['SRCROOT']}/Specs/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :spec
end