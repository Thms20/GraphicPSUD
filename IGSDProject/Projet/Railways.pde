public class Railways {
  PShape railways;
  Map3D map;

  public Railways(Map3D map1, String fileName) {
    this.map = map1;
    PShape lane;
    this.railways = createShape(GROUP);
    float laneWidth = 0.5f;
    PVector va, vb, vc;
    // Check ressources
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
      return;
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(fileName);                                                  // Construction de la lignee du RER B.
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

      lane = createShape();                                          // déclaration ici pour pouvoir créer plusieurs lane et les ajouter plus bas à chaque fois au groupe
      //      this.lane.beginShape(LINE_STRIP);
      lane.beginShape(QUAD_STRIP);

      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      case "LineString":

        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null) {
          if (coordinates.size() == 2) {
            for (int p=0; p < coordinates.size()-1; p++) {
              JSONArray pointA = coordinates.getJSONArray(p);
              JSONArray pointB = coordinates.getJSONArray(p+1);

              Map3D.GeoPoint geoA = this.map.new GeoPoint( pointA.getDouble(0), pointA.getDouble(1));
              Map3D.GeoPoint geoB = this.map.new GeoPoint( pointB.getDouble(0), pointB.getDouble(1));

              geoA.elevation += 7.5d;
              geoB.elevation += 7.5d;

              Map3D.ObjectPoint objA = this.map.new ObjectPoint(geoA);
              Map3D.ObjectPoint objB = this.map.new ObjectPoint(geoB);

              va = new PVector(objA.y - objB.y, objB.x - objA.x).normalize().mult(laneWidth/2.0f);
              
              lane.stroke(0xFFFFFFFF);
              
              if(geoA.inside()) {
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(objA.x - va.x, objA.y - va.y, objA.z);
              lane.normal(0.0f, 0.0f, 1.0f);
              lane.vertex(objA.x + va.x, objA.y + va.y, objA.z);
            }
            
            if(geoB.inside()) {
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

              geoA.elevation += 7.5d;
              geoB.elevation += 7.5d;
              geoC.elevation += 7.5d;

              Map3D.ObjectPoint objA = this.map.new ObjectPoint(geoA);
              Map3D.ObjectPoint objB = this.map.new ObjectPoint(geoB);
              Map3D.ObjectPoint objC = this.map.new ObjectPoint(geoC);

              va = new PVector(objA.y - objB.y, objB.x - objA.x).normalize().mult(laneWidth/2.0f);
              vb = new PVector(objA.y - objC.y, objC.x - objA.x).normalize().mult(laneWidth/2.0f);
              vc = new PVector(objB.y - objC.y, objC.x - objB.x).normalize().mult(laneWidth/2.0f);

              lane.stroke(0xFFFFFFFF);

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
        }
        break;
      case "Point":
        if (geometry.hasKey("coordinates")) {
          JSONArray point = geometry.getJSONArray("coordinates");
          String description = "Pas d'information.";
          if (feature.hasKey("properties")) {
            description = feature.getJSONObject("properties").getString("desc", description);
          }
        }
        break;
      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
        break;
      }
      lane.endShape();
      this.railways.addChild(lane);
    }
    this.railways.setVisible(true);
  }

  void update() {
    shape(this.railways);
  }

  void toggle() {
    this.railways.setVisible(!this.railways.isVisible());
  }
}