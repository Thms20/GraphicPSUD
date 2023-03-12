public class WorkSpace {
  private final int dalle;
  public final int size;
  private PShape gizmo;
  private PShape grid;

  public WorkSpace(int size) {
    this.size  = size;
    this.dalle = round(size/100);
    
    
        // Grid
    this.grid = createShape();
    this.grid.beginShape(QUADS);
    this.grid.noFill();
    this.grid.stroke(0x77836C3D);
    this.grid.strokeWeight(0.5f);
    for (float i = -this.size/2 + this.dalle/2; i < this.size/2; i += this.dalle) {
      for (float j = -this.size/2 + this.dalle/2; j < this.size/2; j += this.dalle) {
        this.grid.vertex(i-dalle/2, j-dalle/2, 0);
        this.grid.vertex(i+dalle/2, j-dalle/2, 0);
        this.grid.vertex(i+dalle/2, j+dalle/2, 0);
        this.grid.vertex(i-dalle/2, j+dalle/2, 0);
      }
    } 
    this.grid.endShape();
    
    // Gizmo
    this.gizmo = createShape();
    this.gizmo.beginShape(LINES);
    this.gizmo.noFill();
    this.gizmo.strokeWeight(3.0f);
    // Red X
    this.gizmo.stroke(0xAAFF3F7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(this.dalle, 0, 0);
    
    this.gizmo.strokeWeight(0.8f);
    this.gizmo.vertex(-this.size/2, 0, 0);
    this.gizmo.vertex(this.size/2,0,0);
    // Green Y
    this.gizmo.stroke(0xAA3FFF7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, this.dalle, 0);
    
    this.gizmo.strokeWeight(0.8f);
    this.gizmo.vertex(0, -this.size/2, 0);
    this.gizmo.vertex(0,this.size/2,0);
    // BLUE Z
    this.gizmo.stroke(0xAA3F7FFF);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, 0, this.dalle);
    this.gizmo.endShape();

  }

  void update() {
    shape(this.grid);
    shape(this.gizmo);
  }

  /**
   * Toggle Grid & Gizmo visibility.
   */
  void toggle() {
    this.grid.setVisible(!this.grid.isVisible());
    this.gizmo.setVisible(!this.gizmo.isVisible());
  }
}