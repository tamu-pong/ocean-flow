require('lib/setup')

Spine = require('spine')
jQuery = require('jqueryify')


class App extends Spine.Controller
  
  events:
    "resize" : "resize"
    "change #radio input" : "select"
    
  elements:
    "header":     "header"
    "footer":     "footer"
    "#map_canvas":     "map_canvas"
    "#radius":     "radius"
    "#single":     "single"
  
  constructor: ->
    super
    
    @log("el", @el)
    @log("map_canvas", @map_canvas)
    
    center = new google.maps.LatLng(24.5, -89.5)
    
    myOptions =
          zoom: 6 
          # center:  if state.center then state.center else myLatLng
          center:  center
          mapTypeId: google.maps.MapTypeId.TERRAIN
          
          streetViewControl:false
          mapTypeControl:true
          zoomControl:true
          scaleControl:true
          panControl:true
          overviewMapControl:true
            
          mapTypeControlOptions:
            mapTypeIds: [google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.SATELLITE]
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
    
    @map = new google.maps.Map(@map_canvas[0], myOptions)
    
    @el[0].onresize = @resize
    
    $( "#radio" ).buttonset();
    
    now = new Date()
    m = 1+now.getMonth()
    m = '0' + m if m<10  
    d = now.getDay()
    d = '0' + d if d<10  
    $( "#datepicker" ).val( m + "/" + d + "/"  + now.getFullYear() + " " + now.getHours() + ":" + now.getMinutes())
    $( "#datepicker" ).datetimepicker
      showOn: "button"
      buttonImage: "images/calendar_icon1.png"
      alwaysSetTime: true
      
    
    @resize();
    
    
  select: (e)->
    s = $(e.target)
    
    if s.attr('id') == 'single' and s.attr('checked') and @radius.attr('checked')
      @radius.click()
    else if s.attr('id') == 'radius' and s.attr('checked') and @single.attr('checked')
      @single.click()
    
    if @radius.attr('checked') or @single.attr('checked')
      @map.setOptions
        draggable:false
        draggableCursor: 'crosshair'
        
  size: ()->
    return @el.height() - @header.height() - @footer.height();
     
  resize: (e)=>
    @map_canvas.height(@size());
    
module.exports = App
    

