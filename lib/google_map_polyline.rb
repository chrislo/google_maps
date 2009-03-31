class GoogleMapPolyline
  #include Reloadable
  include UnbackedDomId
  
  attr_accessor :vertices,
    :color,
    :weight,
    :opacity
  
  def initialize(options = {})
    self.vertices = []
    self.color = "#000"
    self.weight = 1
    self.opacity = 1
    options.each_pair { |key, value| send("#{key}=", value) }
  end
    
  def to_js
    
    js = []
    js << "#{dom_id}_vertices = new Array();"
    vertices.each_with_index do |latlng, index|
      js << "#{dom_id}_vertices[#{index}] = new GLatLng(#{latlng[0]}, #{latlng[1]});"
    end
    
    js << "#{dom_id} = new GPolyline(#{dom_id}_vertices, '#{color}', #{weight}, #{opacity});"
    
    js.join "\n"
  end  
end
