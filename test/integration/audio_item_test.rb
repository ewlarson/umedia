require 'test_helper'

class AudioTest < ActiveSupport::TestCase
  def teardown
    super
    Capybara.current_driver = :selenium_chrome_headless
  end
  it 'loads a kaltura audio player' do
    # Capybara.current_driver = :selenium
    visit '/item/p16022coll171:1706'
    _(has_selector?(:xpath, '//*[@id="kaltura_player_ifp"]')).must_equal true
  end
end
