class Particle {
  PVector center;
  float radius;
  float lifespan;
  Cylinder cylinder;

  Particle(PVector center, float radius) {
    this.center = center.copy();
    this.lifespan = 1000;
    this.radius = radius;
    cylinder = new Cylinder(center);
  }

  void run() {
    update();
    display();
  }

  // Method to update the particles remaining lifetime
  void update() {
    lifespan -= 1;
  }

  // Method to display
  void display() {  
    cylinder.draw();
  }
  
  boolean isDead() {
    return lifespan == 0 ;
  }
}
