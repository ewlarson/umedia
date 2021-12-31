require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/autorun"
require 'mocha/minitest'
require 'webmock/minitest'

WebMock.enable!

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

#### CAPYBARA / SELENIUM
# Capybara config with docker-compose environment vars
require 'webdrivers'
require "webdrivers/chromedriver"
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara/minitest/spec'
require 'capybara-screenshot/minitest'

require 'selenium-webdriver'
require 'webdrivers'

Capybara.register_driver(:headless_chrome) do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    opts.args << '--window-size=1280,1024'
  end
  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 http_client: http_client,
                                 options: browser_options)
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 120

Capybara.asset_host = ENV['RAILS_BASE_URL']
Capybara.save_path = "#{Rails.root}/tmp/screenshots"

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

module CapybaraExtension
  def drag_by(right_by, down_by)
    base.drag_by(right_by, down_by)
  end
end

module CapybaraSeleniumExtension
  def drag_by(right_by, down_by)
    driver.browser.action.drag_and_drop_by(native, right_by, down_by).perform
  end
end
::Capybara::Selenium::Node.send :include, CapybaraSeleniumExtension
::Capybara::Node::Element.send :include, CapybaraExtension


class ActiveSupport::TestCase
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
