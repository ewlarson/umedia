require 'test_helper'

class SmallCompoundTest < ActiveSupport::TestCase
  def teardown
    super
    Capybara.use_default_driver
  end
  it 'loads the OSD viewer and a clickable list of sidebar child pages' do
    Capybara.current_driver = :selenium
    visit '/item/p16022coll474:4419'
    find(:xpath, '//*[@id="osd-config"]')['data-config'].must_equal "{\"currentRotation\":0,\"defaultZoomLevel\":0,\"tileSources\":[\"https://cdm16022.contentdm.oclc.org/digital/iiif/p16022coll474/4387/info.json\"],\"sequenceMode\":false,\"showReferenceStrip\":false,\"showNavigator\":true,\"id\":\"osd-viewer\",\"visibilityRatio\":1.0,\"constrainDuringPan\":false,\"minZoomLevel\":0,\"maxZoomLevel\":10,\"zoomInButton\":\"zoom-in\",\"zoomOutButton\":\"zoom-out\",\"rotateRightButton\":\"rotate-right\",\"rotateLeftButton\":\"rotate-left\",\"homeButton\":\"reset\",\"fullPageButton\":\"full-page\",\"previousButton\":\"sidebar-previous\",\"nextButton\":\"sidebar-next\"}"
    find(:xpath, '//*[@id="sidebar-p16022coll474:4388"]').click
    find(:xpath, '//*[@id="osd-config"]')['data-config'].must_equal "{\"currentRotation\":0,\"defaultZoomLevel\":0,\"tileSources\":[\"https://cdm16022.contentdm.oclc.org/digital/iiif/p16022coll474/4388/info.json\"],\"sequenceMode\":false,\"showReferenceStrip\":false,\"showNavigator\":true,\"id\":\"osd-viewer\",\"visibilityRatio\":1.0,\"constrainDuringPan\":false,\"minZoomLevel\":0,\"maxZoomLevel\":10,\"zoomInButton\":\"zoom-in\",\"zoomOutButton\":\"zoom-out\",\"rotateRightButton\":\"rotate-right\",\"rotateLeftButton\":\"rotate-left\",\"homeButton\":\"reset\",\"fullPageButton\":\"full-page\",\"previousButton\":\"sidebar-previous\",\"nextButton\":\"sidebar-next\"}"
  end
  it 'loads the OSD viewer and a clickable list of sidebar child pages' do
    Capybara.current_driver = :selenium
    visit '/item/p16022coll474:4419'
    find(:xpath, '//*[@id="metadata-transcriptions"]').click
    find(:xpath, '//*[@id="metadata-area"]/div[26]/div').text.must_equal "Page 2 Mr. David Mercer Colloquially, keep them poor and barefoot; and they won't leave home. Sincerely, President & CEO DNM, Jr/vw cc: Ben Casey Bob Knowing Ralph Christian Carol James Eric Mann Tino Mantella Fred Matthews harold Mezile Angela Rice Jim Russell John Scott Deborah Williams Ken Barnes Everett Christmas Tere Lithgow Gordon Mack Ron Sargent Peter Smith Norman Urquhart"
  end
  it 'sidebar pages are searchable' do
    Capybara.current_driver = :selenium
    visit '/item/p16022coll474:4419'
    fill_in 'q', with: 'butler'
    sleep 2
    find(:xpath, '//*[@id="sidebar"]/form/div/span/button').click
    find(:xpath, '//*[@id="sidebar-p16022coll474:4387"]/div[2]/div[2]').text.must_equal "ROBERT DIXON 0f YOUNG MENS CHRISTIAN ASSOCIATION 22 BUTLER STREET, NORTHEAST ATLANTA, GEORGIA 30335 EXECUTIVE RETREAT 22 Butler Street, NE October 4-5, 1993 Board Room AGENDA m pi RECTORS NRIETTA ANTOININ JHER BENATOR iEBORAH BROWDER ROSA BURNEY DR."
    # Page 2 doesn't show up for this search result
    has_selector?(:xpath, '//*[@id="sidebar-p16022coll474:4388"]/div/img').must_equal false
    # Clear the search
    find(:xpath, '//*[@id="sidebar-pages"]/div/a').click
    # Page 2 should be back in the list now
    has_selector?(:xpath, '//*[@id="sidebar-p16022coll474:4388"]/div/img').must_equal true
  end
end
