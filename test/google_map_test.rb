require File.dirname(__FILE__) + '/test_helper'

class GoogleMapTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    @map = GoogleMap.new
  end

  def test_new_map_has_empty_markers
    assert @map.markers.empty?
  end

  def test_add_markers
    @map.markers << GoogleMapMarker.new(:map => @map, 
                                        :lat => 47.6597, 
                                        :lng => -122.318,
                                        :html => 'My House')
    assert_equal @map.markers.length, 1
  end

end
