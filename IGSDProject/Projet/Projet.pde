WorkSpace workspace;                                            // Ici je déclare les variables globales.
Camera camera;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;
Poi poi;
PShader myShader;


// Projet réalisé par Thomas Combeau en L2 Info.

void setup() {
  
  // Setup Head Up Display
  this.hud = new Hud();                                                        // Ici j'initialise les variables globables.

  // Make camera move easier
  hint(ENABLE_KEY_REPEAT);

  this.workspace = new WorkSpace(25000);
  this.camera = new Camera();

  // Load Height Map
  this.map = new Map3D("paris_saclay.data");                                               // Je charge aussi les fichers de data et GEOJSON ici.

  this.land = new Land(this.map);

  this.gpx = new Gpx(this.map, "trail.geojson");

  this.railways = new Railways(this.map, "railways.geojson");

  this.roads = new Roads(this.map, "roads.geojson");

  this.poi = new Poi(this.map);

  // Prepare buildings
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd); 
  
  this.land.distPointInteret(this.poi);
  
  myShader = loadShader("FragmentShader.glsl", "TextureVertex.glsl");                    // Je charge le shader.
  
  // fullScreen(P3D);
  size(1200, 700, P3D);

  background(0);

  smooth(8);
  frameRate(15);                      // Le frameRate est bas car mon ordinateur n'est plus très performant.
}

void draw() {
  background(0);
  
  this.camera.update();                                    // Dans le draw, j'appelle les méthodes update() de chaque classe pour "mettre à jour" leurs états.

  this.workspace.update();
  shader(myShader);                                      // Le shader est appliqué sur Land.
  this.land.update();
  resetShader();
  this.gpx.update();
  this.railways.update();
  this.roads.update();
  this.buildings.update();
  this.hud.update(camera);
}

void keyPressed() {                   // Cette méthode me permet d'afficher le contenu des classes correspondantes des méthodes toggle() à partir des touches claviers.
  switch (key) {
  case 'l':
  case 'L':
    this.camera.toggle();
    break;
  case 'w':
  case 'W':
    // Hide/Show grid & Gizmo
    this.workspace.toggle();

    // Hide/Show Land
    this.land.toggle();
    break;
  case 'x':
    this.gpx.toggle();
    break;
  case 'r':
    this.railways.toggle();
    this.roads.toggle();
    break;
  case 'b':
    this.buildings.toggle();
  }

  if (key == CODED) {                            // Ici je fais bouger la Camera avec les flèches directionnelles. 
    switch (keyCode) {
    case UP:
      camera.adjustColatitude(-PI/200);
      break;
    case DOWN:
      camera.adjustColatitude(PI/200);
      break;
    case LEFT:
      camera.adjustLongitude(-PI/200);
      break;
    case RIGHT:
      camera.adjustLongitude(PI/200);
      break;
    }
  } else {                         // Ici je peux zoomer et  dézoomer avec + et -.
    switch (key) {
    case '+':
      camera.adjustRadius(-400);
      break;
    case '-':
      camera.adjustRadius(400);
      break;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float ec = event.getCount();
  camera.adjustRadius(ec*100);
}
                                            // Les deux méthodes mouseWheel et mouseDragged me permettent de contrôler la Camera avec la souris et sa molette au centre.
void mouseDragged() {
  if (mouseButton == CENTER) {
    // Camera Horizontal
    float dx = mouseX - pmouseX;
    camera.adjustLongitude(dx*2*PI/width);
    // Camera Vertical
    float dy = mouseY - pmouseY;
    camera.adjustColatitude(dy*PI/height);
  }
}

void mousePressed() {                            // Cette méthode me permet d'appliquer la méthode clic() de la classe gpx, donc de changer la couleur de la tête d'épingle sélectionnée.
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY, this.camera);
}