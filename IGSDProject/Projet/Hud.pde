class Hud {
  private PMatrix3D hud;

  Hud() {
    // Should be constructed just after P3D size() or fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
  }

  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }

  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }

  private void displayFPS() {                          // Affiche en as à gauche le FPS en temps réel.
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, height-30, 60, 20, 5, 5, 5, 5);
    // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(String.valueOf((int)frameRate) + " fps", 40, height-20);
  }

  private void displayCamera(Camera camera) {                     // Affiche la longitude, latitude et le radius en temps réel en haut à gauche.
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 10, 120, 90, 5, 5, 5, 5);
    // Value 
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Camera", 70, 15);
    text("Longitude      " + round((camera.longitude > 0 ? camera.longitude : (2*PI + camera.longitude))*360/(2*PI)) + "°", 70, 40);
    text("Latitude         " + String.valueOf(round(degrees(HALF_PI - camera.colatitude))) + "°", 70, 63);
    text("Radius      " + round(camera.radius) + "m", 70, 85);
  }
  
/*  text("Longitude         " + String.valueOf(round(degrees(camera.longitude))) + "°", 70, 40);                            // Autre façon de convertir et afficher le texte.
    text("Latitude         " +String.valueOf(round(degrees(HALF_PI - camera.colatitude)))+ "°", 150, 63);
    text("Radius            " +String.valueOf(round(camera.radius))+ " m", 70, 85); */

  public void update(Camera camera) {  // Met à jour la Caméra.
    this.begin();
    this.displayFPS();
    this.displayCamera(camera);
    this.end();
  }
}