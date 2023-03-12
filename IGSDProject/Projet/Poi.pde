public class Poi {
  Map3D map;

  public Poi(Map3D map1) {
    this.map = map1;
  }

  ArrayList<PVector> getPoints(String fileName) {           // Méthode qui récupère les points d'intérets en PVector dans une liste. Ils repréentent les zones de picnic. 
    ArrayList<PVector> points = new ArrayList<PVector>();
    File ressource = dataFile(fileName);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + fileName + " not found.");
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(fileName);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
    }
    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
    }

    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      JSONObject geometry = feature.getJSONObject("geometry");
      JSONArray coordinates;
      JSONObject properties = feature.getJSONObject("properties");


      if (!feature.hasKey("geometry"))
        break;

      switch (geometry.getString("type", "undefined")) {
      case "Point":
        coordinates = geometry.getJSONArray("coordinates");

          Map3D.GeoPoint geo = this.map.new GeoPoint( coordinates.getDouble(0), coordinates.getDouble(1));
          Map3D.ObjectPoint obj = this.map.new ObjectPoint(geo);
          PVector point;
          point =  new PVector(obj.x, obj.y, obj.z);
          if(obj.inside()) {
          points.add(point);
          }


          break;
          
        default:
          println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometry type not handled.");
          break;
      }
    }
    return points;
  }
 
}