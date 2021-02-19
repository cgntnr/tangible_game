class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  Cylinder villainCylinder;
  float particleRadius = 15;
  boolean game_started = false;
  boolean insideBoard = false;
  float halfBoard = 200;
  float negativePoints;
  float total;
  float velocityAmount;
  float last;

  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    PVector center;
    int numAttempts = 300;
    for (int i=0; i<numAttempts; i++) {

      center = villainCylinder.position.copy();
      float angle = random(TWO_PI);
      center.x += sin(angle) * int(random(0, 5*particleRadius));
      center.y += cos(angle) * int(random(0, 5*particleRadius));

      if (checkPosition(center)) {
        particles.add(new Particle(center, particleRadius));
        total -= 2;
        break;
      }
    }
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center) {
    if (!insideBoard(center) || checkOverlap(center, villainCylinder.position)  ) {
      return false;
    }
    for (int i=0; i<particles.size(); i++) {
      if (checkOverlap(center, particles.get(i).center)) {
        return false;
      }
    }
    return true;
  }

  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    double distance = dist(c1.x, c1.y, c2.x, c2.y);
    return  distance < (2 * particleRadius);
  }

  //Iteratively update and display every particle,
  //and remove them from the list if their lifetime is over.
  void run() {
    if (frameCount % 30 == 1 && game_started) {
      addParticle();
    }
    for (int i=0; i<particles.size(); i++) {
      if (particles.get(i).isDead()) {
        particles.remove(i);
      }
      particles.get(i).update();
      if (mover.checkCylinderCollision(particles.get(i).center)) {
        mover.collisionEffect(particles.get(i).center);
        particles.remove(i);
        velocityAmount = mover.velocity.mag();
        total += velocityAmount;
      }
    }
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).display();
    }
  }

  //returns true if the position is inside the board boundaries, false otherwise
  //200 == half of board width and length
  boolean insideBoard(PVector center) {
    return ((center.x > -halfBoard + particleRadius ) && (center.x < halfBoard - particleRadius) && 
      (center.y > -halfBoard +particleRadius)  && (center.y < halfBoard -particleRadius) );
  }

  void addVillain(PVector v) {
    villainCylinder = new Cylinder(v);
  }

  void deleteVillain() {
    villainCylinder = null;
  }

  void removeAllParticles() {
    for (int i = particles.size()-1; i >= 0; i--) {
      particles.remove(i);
    }
  }
}
