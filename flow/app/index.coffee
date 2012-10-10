require('lib/setup')

Spine = require('spine')
jQuery = require('jqueryify')

CurrentsOverlay = require('lib/surface_current_overlay')
SimpleMap = require('lib/map_types/styled_map')

class App extends Spine.Controller
  
  events:
    "resize" : "resize"
    "change #surface-currents" : "select"
    "click #clear-state" : "clear_state"
    "click #help-button" : "open_help"
    
  elements:
    "header":     "header"
    "footer":     "footer"
    "#map_canvas":     "map_canvas"
    "#surface-currents":     "currents"
  
  constructor: ->
    super
    
    @log("el", @el)
    @log("map_canvas", @map_canvas)
    
    $('.js-button').button()
    $('.js-button-wavy-icon').button
      icons: {'primary': 'ui-icon-wavy'}
      text: false
    
    @setup_tutorial()
    
    center = new google.maps.LatLng(26.5, -89.5)
    
    myOptions =
          zoom: 7
          # center:  if state.center then state.center else myLatLng
          center:  center
          mapTypeId: google.maps.MapTypeId.TERRAIN
          
          streetViewControl:false
          mapTypeControl:true
          zoomControl:true
          scaleControl:true
          panControl:true
          overviewMapControl:true
          disableDoubleClickZoom: true
          mapTypeControlOptions:
            mapTypeIds: [google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.SATELLITE, SimpleMap.ID]
            style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR
            position: google.maps.ControlPosition.BOTTOM_CENTER
    
    @map = new google.maps.Map(@map_canvas[0], myOptions)

    @map.mapTypes.set(SimpleMap.ID, SimpleMap);
    @map.setMapTypeId(SimpleMap.ID);
    
    @el[0].onresize = @resize
    
    now = new Date()
    m = 1+now.getMonth()
    m = '0' + m if m<10  
    d = now.getDay()
    d = '0' + d if d<10  
    $( "#datepicker" ).val( m + "/" + d + "/"  + now.getFullYear() + " " + now.getHours() + ":" + now.getMinutes());
    $( "#datepicker" ).datetimepicker
      showOn: "button"
      buttonImage: "images/calendar_icon1.png"
      alwaysSetTime: true
    
    @resize();
    @el.keyup(@key_press)
    
    @dragging = false

    google.maps.event.addListener(@map, 'mousedown', @map_dragstart);
    google.maps.event.addListener(@map, 'mousemove', @map_drag);
    @el.mouseup(@map_dragstop);
    google.maps.event.addListener(@map, 'mouseout', @map_dragstop);
    
    @markers = []

  key_press: (e) =>
    if e.keyCode == 27 #ESC
      if @currents.attr('checked')
        @currents.click()
      
    
  select: (e)->
    s = $(e.target)
    @clear_state()
    
    do_currents = @currents.attr('checked')
    
    @log("do_currents", do_currents)
    
    if do_currents
      @log("OK")
      @map.setOptions
        draggable:false
        draggableCursor: 'crosshair'
    else
      @log("No")
      @map.setOptions
        draggable:true
        draggableCursor:  'url(http://maps.gstatic.com/mapfiles/openhand_8_8.cur), crosshair'
        
  size: ()->
    return @el.height() - @header.height() - @footer.height();
     
  resize: (e)=>
    @map_canvas.height(@size());
    
    
  clear_state: () =>
    @log("clear_state")
    if @circle 
      @circle.setMap(null)
      
    (marker.setMap(null) for marker in @markers)
    
    @markers = []
    
  map_click_single: (e) =>
    @log('map_click_single')
    marker = new google.maps.Marker
      map:@map
      draggable:true
      animation: google.maps.Animation.DROP
      position: e.latLng
    @log('map_click_single', marker)
      
    @markers.push(marker)
    
    
  map_dragstart: (e) =>
    if not @currents.attr('checked')
      return
    @dragging = true
    
    if @circle
      @circle.setMap(null)
      
    @circle = new google.maps.Circle
      strokeColor: '#FF0000'
      strokeOpacity: 0.8
      strokeWeight: 2
      fillColor: '#FF0000'
      fillOpacity: 0.35
      map: @map
      center: e.latLng
      clickable:false
      radius: 0

  map_dragstop: (e) =>
    @log("map_dragstop")
    @dragging = false
    
    if not @currents
      @clear_state()
      
    if @circle
      @log("circle")
      @circle.setOptions
        fillColor: '#EEE'
        strokeOpacity: 0
        
      if not @circle.getRadius()
        @log("no radius")
        @circle.setMap(null)
        marker = new google.maps.Marker
          map:@map
          draggable:true
          animation: google.maps.Animation.DROP
          position: @circle.getCenter()
        @circle = null
        @markers.push(marker)
        
      
    
  map_drag: (e) =>
    if not @dragging or not @currents.attr('checked') 
      return
      
    radius = google.maps.geometry.spherical.computeDistanceBetween(@circle.getCenter(), e.latLng)
    @log("radius",radius)
    @circle.setRadius(radius)
  
  setup_tutorial: () ->
    
    $('#date-help-box').dialog
      autoOpen:false
      title: 'Start Date'
      resizable: false,
      position: { my: 'left top', at:'center-30px bottom+30px', 'of': '.datetime-container'}
      buttons: 
            "Done": ()->
                $( this ).dialog( "close" )
      dialogClass: 'upper-left-arrow'

    $('#current-help-box').dialog
      autoOpen:false
      title: 'Surface Currents'
      resizable: false,
      position: { my: 'left top', at:'center-30px bottom+30px', 'of': '#currents-item'}
      dialogClass: 'upper-left-arrow'
      buttons: 
            "Next": ()->
                $( this ).dialog( "close" )
                $('#date-help-box').dialog('open')
            "Done": ()->
                $( this ).dialog( "close" )
    
    $('#welcom-box').dialog
      modal:true
      autoOpen:not localStorage.hello
      title: 'Welcome!'
      resizable: false,
      height:240,
      draggable:false
      buttons: 
            "Show me how this works": ()->
                $( this ).dialog( "close" )
                $('#current-help-box').dialog('open')
            "I already know how": ()->
                $( this ).dialog( "close" )

      if typeof(Storage) is "undefined"
        @log("Sorry! No web storage support..")
      else
        # Yes! localStorage and sessionStorage support!
        localStorage.hello = true

  open_help: (e) ->
    $('#welcom-box').dialog('open')

     
module.exports = App
    


