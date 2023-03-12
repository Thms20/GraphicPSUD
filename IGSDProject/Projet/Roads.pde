public class Roads {
  PShape roads;
  Map3D map;
  public Roads(Map3D map1, String fileName) {
    
    this.map = map1;

    this.roads = createShape(GROUP);

    String laneKind = "unclassified";
    color laneColor = 0xFFFF0000;
    double laneOffset = 1.50d;
    float laneWidth = 0.5f;


    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
      return;
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(fileName);                          
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return;
    }
    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return;
    }

    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      JSONObject geometry = feature.getJSONObject("geometry");                    // Construction de toutes les routes selon leurs paramètres.
      JSONArray coordinates;

      JSONObject properties = feature.getJSONObject("properties");
      laneKind = properties.getString("highway", "unclassified");

      switch (laneKind) {
      case "motorway":
        laneColor = 0xFFe990a0;
        laneOffset = 3.75d;
        laneWidth = 8.0f;

        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "trunk":
        laneColor = 0xFFfbb29a;
        laneOffset = 3.60d;
        laneWidth = 7.0f;
        
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "trunk_link":
      case "primary":
        laneColor = 0xFFfdd7a1;
        laneOffset = 3.45d;
        laneWidth = 6.0f;
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "secondary":
      case "primary_link":
        laneColor = 0xFFf6fabb;
        laneOffset = 3.30d;
        laneWidth = 5.0f;
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "tertiary":
      case "secondary_link":
        laneColor = 0xFFE2E5A9;
        laneOffset = 3.15d;
        laneWidth = 4.0f;
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "tertiary_link":
      case "residential":
      case "construction":
      case "living_street":
        laneColor = 0xFFB2B485;
        laneOffset = 3.00d;
        laneWidth = 3.5f;
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      case "corridor":
      case "cycleway":
      case "footway":
      case "path":
      case "pedestrian":
      case "service":
      case "steps":
      case "track":
      case "unclassified":
        laneColor = 0xFFcee8B9;
        laneOffset = 2.85d;
        laneWidth = 1.0f;
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      default:
        laneColor = 0xFFFF0000;
        laneOffset = 1.50d;
        laneWidth = 0.5f;
        println("WARNING: Roads kind not handled : ", laneKind);
                
        coordinates = geometry.getJSONArray("coordinates");
        traceLane(coordinates, laneColor, laneWidth, laneOffset);
        break;
      }
      // Display threshold (increase if more performance needed...)
      if (laneWidth < 1.0f)
        break;
    }

    this.roads.setVisible(false);
  }
  
  void traceLane(JSONArray coordinates, color laneColor,  float laneWidth, double laneOffset) {         // Généralisation de la façon de construire une route.

        if (coordinates != null) {
          
          PShape lane;
          PVector va, vb, vc;
          
          lane = createShape();
          lane.beginShape(QUAD_STRIP);

          if (coordinates.size() == 2) {
            for (int p=0; p < coordinates.size()-1; p++) {
              JSONArray pointA = coordinates.getJSONArray(p);
              JSONArray pointB = coordinates.getJSONArray(p+1);

              Map3D.GeoPoint geoA = this.map.new GeoPoint( pointA.getDouble(0), pointA.getDouble(1));
              Map3D.GeoPoint geoB = this.map.new GeoPoint( pointB.getDouble(0), pointB.getDouble(1));

              geoA.elevation += laneOffset;
              geoB.elevation += laneOffset;

              Map3D.ObjectPoint objA = this.map.new ObjectPoint(geoA);
              Map3D.ObjectPoint objB = this.map.new ObjectPoint(geoB);

              va = new PVector(objA.y - objB.y, objB.x - objA.x).normalize().mult(laneWidth/2.0f);

              lane.stroke(laneColor);

              if (geoA.inside()) {
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objA.x - va.x, objA.y - va.y, objA.z);
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objA.x + va.x, objA.y + va.y, objA.z);
              }

              if (geoB.inside()) {
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objB.x - va.x, objB.y - va.y, objB.z);
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objB.x + va.x, objB.y + va.y, objB.z);
              }
            }
          } else {
            for (int p=0; p < coordinates.size()-2; p++) {

              JSONArray pointA = coordinates.getJSONArray(p);
              JSONArray pointB = coordinates.getJSONArray(p+1);
              JSONArray pointC = coordinates.getJSONArray(p+2);

              Map3D.GeoPoint geoA = this.map.new GeoPoint( pointA.getDouble(0), pointA.getDouble(1));
              Map3D.GeoPoint geoB = this.map.new GeoPoint( pointB.getDouble(0), pointB.getDouble(1));
              Map3D.GeoPoint geoC = this.map.new GeoPoint( pointC.getDouble(0), pointC.getDouble(1));

              geoA.elevation += laneOffset;
              geoB.elevation += laneOffset;
              geoC.elevation += laneOffset;

              Map3D.ObjectPoint objA = this.map.new ObjectPoint(geoA);
              Map3D.ObjectPoint objB = this.map.new ObjectPoint(geoB);
              Map3D.ObjectPoint objC = this.map.new ObjectPoint(geoC);

              va = new PVector(objA.y - objB.y, objB.x - objA.x).normalize().mult(laneWidth/2.0f);
              vb = new PVector(objA.y - objC.y, objC.x - objA.x).normalize().mult(laneWidth/2.0f);
              vc = new PVector(objB.y - objC.y, objC.x - objB.x).normalize().mult(laneWidth/2.0f);

              lane.stroke(laneColor);

              if (geoA.inside()) {
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objA.x - va.x, objA.y - va.y, objA.z);
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objA.x + va.x, objA.y + va.y, objA.z);
              }

              if (geoB.inside()) {
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objB.x - vb.x, objB.y - vb.y, objB.z);
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objB.x + vb.x, objB.y + vb.y, objB.z);
              }

              if (geoC.inside()) {
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objC.x - vc.x, objC.y - vc.y, objC.z);
                lane.normal(0.0f, 0.0f, 1.0f);
                lane.vertex(objC.x + vc.x, objC.y + vc.y, objC.z);
              }
            }
          }
          lane.endShape();
          this.roads.addChild(lane);
        }
  }

  void update() {
    shape(this.roads);
  }

  void toggle() {
    this.roads.setVisible(!this.roads.isVisible());
  }
  
}