var styles = [{
    featureType : "landscape",
    stylers : [{
        color : "#555555"
    }]
}, {
    featureType : "administrative",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType : "poi",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType : "water",
    elementType : "labels",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType: "road",
    stylers: [
      { visibility: "off" }
    ]
},{
    featureType: "administrative.country",
    elementType: "geometry.stroke",
    stylers: [
      { visibility: "on" },
      { weight: 0.75 },
      { color: "#999999" }
    ]
  }]

var SimpleMap = new google.maps.StyledMapType(styles, {
    name : "Simple"
});

SimpleMap.ID = "Simple";

module.exports = SimpleMap; 