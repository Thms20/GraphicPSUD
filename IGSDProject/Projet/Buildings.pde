public class Buildings {
  PShape buildings;

  Map3D map;

  public Buildings(Map3D map1) {
    this.map = map1;

    this.buildings = createShape(GROUP);

    this.buildings.setVisible(false);
  }

  void add(String fileName, color colorBuilding) {

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
      JSONObject geometry = feature.getJSONObject("geometry");                      // J'utilise l'algorithme qui permet de lire des fichiers GEOJSON et de récupérer les coordonnées.
      JSONArray coordinates;
      JSONObject properties = feature.getJSONObject("properties");


      if (!feature.hasKey("geometry"))
        break;

      switch (geometry.getString("type", "undefined")) {
      case "Polygon":
        coordinates = geometry.getJSONArray("coordinates");

        for (int tab=0; tab < coordinates.size(); tab++) {
          JSONArray tabPoint = coordinates.getJSONArray(tab);
          PShape walls;
          PShape roofs;
          int levels = properties.getInt("building:levels", 1);
          float top = Map3D.heightScale * 3.0f * (float)levels;
          walls = createShape();
          walls.beginShape(QUADS);
          
          roofs = createShape();
          roofs.beginShape(POLYGON);
          for (int p = 1; p < tabPoint.size(); p++) {
            JSONArray pointA = tabPoint.getJSONArray(p-1);
            JSONArray pointB = tabPoint.getJSONArray(p);                                                                // Je construis les PShapes walls et roofs 

            Map3D.GeoPoint geoA = this.map.new GeoPoint( pointA.getDouble(0), pointA.getDouble(1));                    // Je transforme les coordonnées récupérés dans le fichier 
            Map3D.GeoPoint geoB = this.map.new GeoPoint( pointB.getDouble(0), pointB.getDouble(1));                    // avec l'objet GeoPoint de la classe Map3D puis avec ObjPoint
                                                                                                                       // de la même classe pour avoir des coordonnées utilisable sur 
            Map3D.ObjectPoint objA = this.map.new ObjectPoint(geoA);                                                   // Processing.
            Map3D.ObjectPoint objB = this.map.new ObjectPoint(geoB);

            walls.stroke(colorBuilding);
            walls.fill(colorBuilding);
            walls.emissive(0x30);
            
            roofs.stroke(colorBuilding);
            roofs.fill(colorBuilding);
            roofs.emissive(0x60);

            if (objA.inside() && objB.inside()) {                                            // Construction d'un QUAD avec 4 vertexs.
              walls.normal(0,0,1);
              walls.vertex(objA.x, objA.y, objA.z);
              walls.normal(0,0,1);
              walls.vertex(objA.x, objA.y, objA.z + top);
              walls.normal(0,0,1);
              walls.vertex(objB.x, objB.y, objB.z + top);
              walls.normal(0,0,1);
              walls.vertex(objB.x, objB.y, objB.z);
              
              roofs.normal(0,0,1);
              roofs.vertex(objA.x, objA.y, objA.z + top);                                  // Construction d'un polygon pour faire le toit.
              roofs.normal(0,0,1);
              roofs.vertex(objB.x, objB.y, objB.z + top);
              
            }
          }
          roofs.endShape(CLOSE);
          this.buildings.addChild(roofs);                                                 // J'ajoute roofs et walls au PShape de type GROUP buildings.
          walls.endShape();
          this.buildings.addChild(walls);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometry type not handled.");
        break;
      }
    }
  }

  void update() {
    shape(this.buildings);
  }

  void toggle() {
    this.buildings.setVisible(!this.buildings.isVisible());
  }
}