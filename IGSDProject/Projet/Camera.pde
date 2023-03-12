public class Camera {
  // Coordonnées sphériques

  private float radius;
  private float longitude;
  private float colatitude;

  // Coordonnées cartésiennes

  private float x;
  private float y;
  private float z;

  // Eclairage
  private boolean lightning;


  public Camera() {
    this.lightning = false;

    this.radius = sqrt(0+(2500*2500)+(1000*1000));                              // Initialisation de radius, longitude et latitude puis de x, y et z selon les trois premiers.
    this.longitude = atan2(2500, 0);
    this.colatitude = acos(1000/this.radius);

    this.x = this.radius * sin(this.colatitude) * cos(this.longitude);
    this.y = this.radius * sin(this.colatitude) * sin(this.longitude);
    this.z = this.radius * cos(this.colatitude);
  }

  void update() {
    // 3D camera (X+ right / Z+ top / Y+ Front)
    this.x = this.radius * sin(this.colatitude) * cos(this.longitude);                         // Mise à jour de x, y et z, puis de la Camera. 
    this.y = this.radius * sin(this.colatitude) * sin(this.longitude);
    this.z = this.radius * cos(this.colatitude);
    camera(
      this.x, -this.y, this.z, 
      0, 0, 0, 
      0, 0, -1
      );

    // Sunny vertical lightning
    ambientLight(0x7F, 0x7F, 0x7F);                                                            // La lumère activé par la touche L.
    if (lightning) {
      directionalLight(0xA0, 0xA0, 0x60, 0, 0, -1);
    }
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);
  }

  void adjustRadius(float offset) {                                                                    // 3 méthodes pour ajuster le radius, la longitude et la latitude.
    float nb = this.radius + offset;
    if ((nb >= width/2)  && (nb <= width*3)) {
      this.radius += offset;
    } else {
      System.out.println("Vous dépassez les limites autorisées avec la fonction adjustRadius.");
    }
  }

  void adjustLongitude(float delta) {
    float nb = this.longitude + delta;
    if ((nb >= -3*PI/2)  && (nb <= PI/2)) {
      this.longitude += delta;
    } else {
      System.out.println("Vous dépassez les limites autorisées avec la fonction adjustLongitude.");
    }
  }

  void adjustColatitude(float delta) {
    float nb = this.colatitude + delta;
    if ((nb >= 1E-6)  && (nb <= PI/2)) {
      this.colatitude += delta;
    } else {
      System.out.println("Vous dépassez les limites autorisées avec la fonction adjustColatitude.");
    }
  }

  void toggle() {
    boolean a  = !this.lightning;
    this.lightning = a;
  }
}