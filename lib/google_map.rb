class GoogleMap
  #include Reloadable
  include UnbackedDomId
  attr_accessor :dom_id,
    :markers,
    :overlays,
    :controls,
    :inject_on_load,
    :zoom,
    :center,
    :double_click_zoom,
    :continuous_zoom,
    :scroll_wheel_zoom,
    :bounds
  
  def initialize(options = {})
    self.dom_id = 'google_map'
    self.markers = []
    self.overlays = []
    self.bounds = []
    self.controls = [ :zoom, :overview, :scale, :type ]
    self.double_click_zoom = true
    self.continuous_zoom = false
    self.scroll_wheel_zoom = false
    options.each_pair { |key, value| send("#{key}=", value) }
  end
  
  def to_html
    html = []
    
    html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"    
    html << "<script type=\"text/javascript\">\n/* <![CDATA[ */\n"  
    html << to_js
    html << "/* ]]> */</script> "
    
    return html.join("\n")
  end

  def to_enable_prefix true_or_false
    true_or_false ? "enable" : "disable"
  end
  
  def to_js
    js = []
    
    # Initialise the map variable so that it can externally accessed.
    js << "var #{dom_id};"
    markers.each { |marker| js << "var #{marker.dom_id};" }
    
    js << markers_functions_js
    
    js << center_map_js
    
    js << "function initialize_google_map_#{dom_id}() {"
    js << "  if(GBrowserIsCompatible()) {"
    js << "    #{dom_id} = new GMap2(document.getElementById('#{dom_id}'));"

    js << " if (self['GoogleMapOnLoad']) {"
    #   added by Patrick to enable load functions
    js << "#{dom_id}.load = GEvent.addListener(#{dom_id},'load',GoogleMapOnLoad)"
    js << "}"
    js << '    ' + controls_js
    
    js << '    ' + center_on_bounds_js
    
    js << '    ' + markers_icons_js
        
    # Put all the markers on the map.
    for marker in markers
      js << '    ' + marker.to_js
      js << ''
    end
    
    overlays.each do |overlay|
      js << overlay.to_js
      js << "#{dom_id}.addOverlay(#{overlay.dom_id});"  
    end

    js << "#{dom_id}.#{to_enable_prefix double_click_zoom}DoubleClickZoom();"
    js << "#{dom_id}.#{to_enable_prefix continuous_zoom}ContinuousZoom();"
    js << "#{dom_id}.#{to_enable_prefix scroll_wheel_zoom}ScrollWheelZoom();"
    
    js << '    ' + inject_on_load.gsub("\n", "    \n") if inject_on_load
    js << "  }"
    js << "}"
    
    # Load the map on window load preserving anything already on window.onload.
    js << "if (typeof window.onload != 'function') {"
    js << "  window.onload = initialize_google_map_#{dom_id};"
    js << "} else {"
    js << "  old_before_google_map_#{dom_id} = window.onload;"
    js << "  window.onload = function() {" 
    js << "    old_before_google_map_#{dom_id}();"
    js << "    initialize_google_map_#{dom_id}();"
    js << "  }"
    js << "}"
    
    # Unload the map on window load preserving anything already on window.onunload.
    #js << "if (typeof window.onunload != 'function') {"
    #js << "  window.onunload = GUnload();"
    #js << "} else {"
    #js << "  old_before_onunload = window.onload;"
    #js << "  window.onunload = function() {" 
    #js << "    old_before_onunload;"
    #js << "    GUnload();" 
    #js << "  }"
    #js << "}"
            
    return js.join("\n")
  end
  
  def controls_js
    js = []
    
    controls.each do |control|
      case control
      when :large, :small, :overview
        c = "G#{control.to_s.capitalize}MapControl"
      when :large_3d
        c = "GLargeMapControl3D"
      when :scale
        c = "GScaleControl"
      when :type
        c = "GMapTypeControl"
      when :menu_type
        c = "GMenuMapTypeControl"
      when :hierachical_type
        c = "GHierarchicalMapTypeControl"
      when :zoom
        c = "GSmallZoomControl"
      when :zoom_3d
        c = "GSmallZoomControl3D"
      when :nav_label
        c = "GNavLabelControl"
      end
      js << "#{dom_id}.addControl(new #{c}());"
    end
    
    return js.join("\n")
  end
  
  def markers_functions_js
    js = []
    
    for marker in markers
      js << marker.open_info_window_function
    end
    
    return js.join("\n")
  end
  
  def markers_icons_js
    icons = []
    
    for marker in markers
      if marker.icon and !icons.include?(marker.icon)
        icons << marker.icon 
      end
    end
    
    js = []
    
    for icon in icons
      js << icon.to_js
    end
    
    return js.join("\n")
  end
    
  # Creates a JS function that centers the map on the specified center
  # location if given to the initialisers, or on the maps markers if they exist, or
  # at (0,0) if not.
  def center_map_js
    
    if self.zoom
      zoom_js = zoom
    else
      zoom_js = "#{dom_id}.getBoundsZoomLevel(#{dom_id}_latlng_bounds)"
    end

    set_center_js = []
    
    if self.center
      set_center_js << "#{dom_id}.setCenter(new GLatLng(#{center[0]}, #{center[1]}), #{zoom_js});"
    else  
      
      synch_bounds
      
      set_center_js << "var #{dom_id}_latlng_bounds = new GLatLngBounds();"
    
      bounds.each do |latlng|
        set_center_js << "#{dom_id}_latlng_bounds.extend(new GLatLng(#{latlng[0]}, #{latlng[1]}));"
      end  
    
      set_center_js << "#{dom_id}.setCenter(#{dom_id}_latlng_bounds.getCenter(), #{zoom_js});"
    end
    
    "function center_#{dom_id}() {\n  #{check_resize_js}\n  #{set_center_js.join "\n"}\n}"
  end
  
  def synch_bounds
    
    overlays.each do |overlay|
      
      if overlay.is_a? GoogleMapPolyline
        bounds << overlay.vertices
      end
    end
    
    markers.each do |marker|
      bounds << [marker.lat, marker.lng]
    end    
    
    bounds.uniq!
  end
  
  def check_resize_js
    return "#{dom_id}.checkResize();"
  end
  
  def center_on_bounds_js
    return "center_#{dom_id}();"
  end
  
  def div(width = '100%', height = '100%')
    "<div id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
  end
end
