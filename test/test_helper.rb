ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'rubygems'
require 'actionpack'
require 'action_view'
require 'lib/unbacked_dom_id'
require 'lib/google_map_icon'
require 'lib/google_map_letter_icon'
require 'lib/google_map_marker'
require 'lib/google_map'
require 'lib/google_map_small_icon'
require 'lib/google_map_geo_xml'
require 'lib/google_map_polyline'

def marker_factory(options = {})
  params = {:map => @map, :lat => 40, :lng => -100, :html => 'Test Marker'}.merge(options)
  GoogleMapMarker.new(params)
end

def polyline_factory(options = {})
  params = {:color => "#00FF00", :weight => 10, :opacity => 2, :vertices => [[40, -100], [40, 100]]}.merge(options)
  GoogleMapPolyline.new(params)
end

def geoxml_factory(options = {})
  params = {:url_of_xml => "http://code.google.com/apis/kml/documentation/KML_Samples.kml"}.merge(options)
  GoogleMapGeoXml.new(params)
end



