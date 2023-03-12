public class Land {
  private PShape shadow;
  private PShape wireFrame;
  private PShape satellite;
  private Map3D map;



  Land(Map3D map) {
    final float tileSize = 25.0f;
    this.map = map;
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();

    // Mon code pour l'ombre portée                     
    this.shadow.vertex(-w/2, -h/2, -5);
    this.shadow.vertex(w/2, -h/2, -5);
    this.shadow.vertex(w/2, h/2, -5);
    this.shadow.vertex(-w/2, h/2, -5); 

    this.shadow.endShape();
    // Code pour le maillage en fil de fer. 
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.noFill();
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);

    for (float y = -h/2.0f; y < h/2.0f; y += tileSize) {
      for (float x = -w/2.0f; x < w/2.0f; x += tileSize) {
        Map3D.ObjectPoint obj = this.map.new ObjectPoint(x, y);
        this.wireFrame.vertex(obj.x, obj.y, obj.z);
        obj = this.map.new ObjectPoint(x + tileSize, y);
        this.wireFrame.vertex(obj.x, obj.y, obj.z);
        obj = this.map.new ObjectPoint(x + tileSize, y + tileSize);
        this.wireFrame.vertex(obj.x, obj.y, obj.z);
        obj = this.map.new ObjectPoint(x, y + tileSize);
        this.wireFrame.vertex(obj.x, obj.y, obj.z);
      }
    }

    this.wireFrame.endShape();

    File ressource = dataFile("paris_saclay.jpg");
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Land texture file " + "paris_saclay.jpg" + " not found.");
      exitActual();
    }

    PImage uvmap = loadImage("paris_saclay.jpg"); // Chargement de l'image de paris saclay, elle et stocké dans la variable uvmap.

    this.satellite = createShape();

    this.satellite.beginShape(QUADS);    
    
    this.satellite.attrib("heat", 0.0f, 0.0f);
    
    this.satellite.texture(uvmap);
    this.satellite.noFill();
    this.satellite.noStroke();

    this.satellite.emissive(0xD0);
    float u, v;
    PVector n;

    for (float y = -h/2.0f; y < h/2.0f; y += tileSize) {
      for (float x = -w/2.0f; x < w/2.0f; x += tileSize) {

        Map3D.ObjectPoint obj = this.map.new ObjectPoint(x, y);
        n = obj.toNormal();
        this.satellite.normal(n.x, n.y, n.z);                                                                 // Code pour la construction de Satellite avec les coordonnées de texture.
        u = map(obj.x, -(float)Map3D.width/2.0f, (float)Map3D.width/2.0f, 0.0f, uvmap.width-1);
        v = map(obj.y, -(float)Map3D.height/2.0f, (float)Map3D.height/2.0f, 0.0f, uvmap.height-1);
        this.satellite.vertex(obj.x, obj.y, obj.z, u, v);

        obj = this.map.new ObjectPoint(x + tileSize, y);    
        n = obj.toNormal();
        this.satellite.normal(n.x, n.y, n.z);
        u = map(obj.x, -(float)Map3D.width/2.0f, (float)Map3D.width/2.0f, 0.0f, uvmap.width-1);
        v = map(obj.y, -(float)Map3D.height/2.0f, (float)Map3D.height/2.0f, 0.0f, uvmap.height-1);
        this.satellite.vertex(obj.x, obj.y, obj.z, u, v);

        obj = this.map.new ObjectPoint(x + tileSize, y + tileSize);
        n = obj.toNormal();
        this.satellite.normal(n.x, n.y, n.z);
        u = map(obj.x, -(float)Map3D.width/2.0f, (float)Map3D.width/2.0f, 0.0f, uvmap.width-1);
        v = map(obj.y, -(float)Map3D.height/2.0f, (float)Map3D.height/2.0f, 0.0f, uvmap.height-1);
        this.satellite.vertex(obj.x, obj.y, obj.z, u, v);

        obj = this.map.new ObjectPoint(x, y + tileSize);
        n = obj.toNormal();
        this.satellite.normal(n.x, n.y, n.z);
        u = map(obj.x, -(float)Map3D.width/2.0f, (float)Map3D.width/2.0f, 0.0f, uvmap.width-1);
        v = map(obj.y, -(float)Map3D.height/2.0f, (float)Map3D.height/2.0f, 0.0f, uvmap.height-1);
        this.satellite.vertex(obj.x, obj.y, obj.z, u, v);
      }
    }

    this.satellite.endShape();


    // Shapes initial visibility
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }

  void update() {
    shape(this.shadow);
    shape(this.wireFrame);
    shape(this.satellite);
  }

  void toggle() {
    //   this.shadow.setVisible(!this.shadow.isVisible());   ---> Doit rester visible
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());
  }

  void distPointInteret(Poi poi) {                                                       // Calcul la distance la plus proche entre chaque points de satellite et des points d'intérêts.
    ArrayList<PVector> pointsInteret = poi.getPoints("picnic.geojson");        
    float d;
    PVector u;

    for (int v = 0; v < this.satellite.getVertexCount(); v++) {
      float dProche;
      u = this.satellite.getVertex(v);
      dProche = dist(pointsInteret.get(0).x, pointsInteret.get(0).y, pointsInteret.get(0).z, u.x, u.y, u.z);
      for (PVector p : pointsInteret) {
        d = dist(p.x, p.y, p.z, u.x, u.y, u.z);
        if (d < dProche) {
          dProche = d;
        }
      }
      this.satellite.setAttrib("heat", v, dProche);
    }
  }
}