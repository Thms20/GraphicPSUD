public class Gpx {
  Map3D map;

  PShape track;
  PShape posts;
  PShape thumbtacks;


  public Gpx(Map3D map1, String fileName) {

    this.map = map1;

    this.track = createShape();
    this.posts = createShape();
    this.thumbtacks = createShape();

    // Test si il existe
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
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {


      case "LineString":
        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null) {

          this.track.beginShape(LINE_STRIP);
          this.track.strokeWeight(3);

          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);

            Map3D.GeoPoint geo = this.map.new GeoPoint( point.getDouble(0), point.getDouble(1));                 // Code pour l'affichage la ligne "track"
            if (geo.inside()) {
              geo.elevation += 2.5d;
              Map3D.ObjectPoint obj = this.map.new ObjectPoint(geo);
              this.track.stroke(0xFFEA1AEA);
              this.track.vertex(obj.x, obj.y, obj.z);
            }
          }

          this.track.endShape();
        }


        break;


      case "Point":
        // GPX WayPoint
        if (geometry.hasKey("coordinates")) {
          JSONArray point = geometry.getJSONArray("coordinates");
          String description = "Pas d'information.";
          if (feature.hasKey("properties")) {
            description = feature.getJSONObject("properties").getString("desc", description);
          }                                                                                                       // Code pour l'affichage des posts et des thumbtacks.
          this.posts.beginShape(LINES);  
          Map3D.GeoPoint geo = this.map.new GeoPoint( point.getDouble(0), point.getDouble(1));                
          if (geo.inside()) {
            geo.elevation += 2.5d;
            Map3D.ObjectPoint obj = this.map.new ObjectPoint(geo);
            this.posts.stroke(0xFFEA1AEA);
            this.posts.strokeWeight(2);
            this.posts.vertex(obj.x, obj.y, obj.z);
            this.posts.vertex(obj.x, obj.y, obj.z+30);
            this.thumbtacks.beginShape(POINTS);
            this.thumbtacks.stroke(0xFFFF3F3F);
            this.thumbtacks.strokeWeight(10);
            this.thumbtacks.vertex(obj.x, obj.y, obj.z+35);
            this.thumbtacks.endShape();
          }
          this.posts.endShape();
        }
        break;
      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometry type not handled.");
        break;
      }
    }
    this.track.setVisible(true);                      // Visibilité de départ 
    this.posts.setVisible(true);
    this.thumbtacks.setVisible(true);
  }

  void update() {
    shape(this.track);
    shape(this.posts);
    shape(this.thumbtacks);
  }

  void toggle() {
    this.track.setVisible(!this.track.isVisible());
    this.posts.setVisible(!this.posts.isVisible());
    this.thumbtacks.setVisible(!this.thumbtacks.isVisible());
  }

  void clic(int x, int y, Camera camera) {                                          // méthode qui change la couleur de la tête d'épingle sélectionné et qui affiche une description
    PVector hit;                                                                    // pour la tête d'épingle tout en bas.
    float d;
    float[] tab;
    tab = new float[this.thumbtacks.getVertexCount()];
    for (int v = 0; v < this.thumbtacks.getVertexCount(); v++) {
      hit = this.thumbtacks.getVertex(v);
      d = dist(x, y, screenX(hit.x, hit.y, hit.z), screenY(hit.x, hit.y, hit.z));
      tab[v] = d;
    }

    for (int p = 0; p < this.thumbtacks.getVertexCount(); p++) {
      if (tab[p] <= -5 || tab[p] >= 5) {
        this.thumbtacks.setStroke(p, 0xFFFF3F3F);
      } else {
        this.thumbtacks.setStroke(p, 0xFF3FFF7F);
        
        if (p == this.thumbtacks.getVertexCount()-1) {
          
          hit = this.thumbtacks.getVertex(p);
          
          pushMatrix();
          lights();
          fill(0xFFFFFFFF);
          translate(hit.x, hit.y, hit.z + 10.0f);
          rotateZ(-camera.longitude-HALF_PI);
          rotateX(-camera.colatitude);
          g.hint(PConstants.DISABLE_DEPTH_TEST);
          textMode(SHAPE);
          textSize(48);
          textAlign(LEFT, CENTER);
          text("Parking Bâtiment 333", 0, 0);
          g.hint(PConstants.ENABLE_DEPTH_TEST);
          popMatrix();
        }
      }
    }
  }
}