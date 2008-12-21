require File.dirname(__FILE__) + '/test_helper'

GOOGLE_APPLICATION_ID = "ABQIAAAA3HdfrnxFAPWyY-aiJUxmqRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQ0KYLwBEKSM7F9gCevcsIf6WPuIQ"

class GoogleMapTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    @map = GoogleMap.new
    @marker = GoogleMapMarker.new(:map => @map, 
                                  :lat => 40, 
                                  :lng => -100,
                                  :html => 'Test Marker')
  end

  def test_new_map_has_empty_markers
    assert @map.markers.empty?
  end

  def test_add_markers
    @map.markers << @marker
    assert_equal @map.markers.length, 1
    assert @map.to_html.include? "google_map_marker_1 = new GMarker(new GLatLng(40, -100));"
  end
  
  def test_center_on_markers_function_for_empty_map
    assert @map.center_on_markers_function_js.include? "google_map.setCenter(new GLatLng(0, 0), 0);"
  end

  def test_center_on_markers_function_for_one_marker
    @map.markers << @marker
    assert @map.center_on_markers_function_js.include? "new GLatLngBounds(new GLatLng(40, -100), new GLatLng(40, -100))"
  end

  def test_center_on_markers_function_for_two_markers
    @map.markers << @marker
    @map.markers << GoogleMapMarker.new(:map => @map, :lat => 40, :lng => 100, :html => 'Test Marker')
    assert @map.center_on_markers_function_js.include? "new GLatLngBounds(new GLatLng(40, -100), new GLatLng(40, 100))"
  end
  
end
