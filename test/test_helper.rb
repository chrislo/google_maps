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

def marker_factory(options = {})
  params = {:map => @map, :lat => 40, :lng => -100, :html => 'Test Marker'}.merge(options)
  GoogleMapMarker.new(params)
end


