class Mover { 
  PVector location = new PVector(0, 0, 0);
  PVector velocity = new PVector(0, 0, 0);
  PVector gravityForce = new PVector(0, 0, 0);
  float halfBoard = 200;
  float sphere_radius = 16;
  float gravityConstant = 1;
  float normalForce = 1;
  float mu = 0.4;
  float frictionMagnitude = 0.5 * normalForce * mu; 
  //for testvideo part we decreased the friction because otherwise
  //it would move too little
  float cylinderRadius = 15;
  float epsilon = 0.01;
  float moverZPos = 21 ; // 21 for sphere_radius + box_height/2
  


  Mover() {
    location = new PVector(0, 0, moverZPos); 
    velocity = new PVector(0, 0, 0);
  }
  void update() {
    gravityForce.x = sin(rotateValY) * gravityConstant;
    gravityForce.y = -sin(rotateValX) * gravityConstant; 
    gravityForce.z = -1;

    PVector friction = velocity.copy();

    friction.mult(-1);
    friction.normalize(); 
    friction.mult(frictionMagnitude);

    velocity.add(friction);
    velocity.add(gravityForce);
    location.add(velocity);
  }
  void display() { 
    gameSurface.noStroke();
    gameSurface.lights();
    gameSurface.translate(location.x, location.y, location.z);
    gameSurface.fill(255, 0, 0);
    gameSurface.sphere(sphere_radius);
    topView.fill(255, 0, 0);
    topView.ellipse(10, 10, sphere_radius*2, sphere_radius*2 );
  }
  void checkEdges() {

    if (location.x > halfBoard - sphere_radius) {
      velocity.x = velocity.x * -1;
      location.x = halfBoard - sphere_radius;
    }
    if (location.x < -halfBoard + sphere_radius) {
      velocity.x = velocity.x * -1;
      location.x = -halfBoard + sphere_radius;
    }
    if (location.y > halfBoard - sphere_radius) {
      velocity.y = velocity.y * -1;
      location.y = halfBoard - sphere_radius;
    }
    if (location.y < -halfBoard + sphere_radius) {
      velocity.y = velocity.y * -1;
      location.y = -halfBoard + sphere_radius;
    }

    if (location.z < moverZPos) {
      velocity.z = velocity.z * -1;
      location.z = moverZPos;
    }
  }


  //two methods for bouncing 
  boolean checkCylinderCollision(PVector cylinder) {
    float distance = dist(location.x, location.y, cylinder.x, cylinder.y);
    if (distance <= cylinderRadius + sphere_radius + epsilon) { 
      return true;
    }
    return false;
  }

  void collisionEffect(PVector cylinder) {
    PVector dist = cylinder.copy().sub(location);
    PVector n = dist.normalize();
    location = location.copy().sub(dist);
    velocity = velocity.copy().sub(n.mult(2*velocity.copy().dot(n)));  
  }

  float vectorNorm(PVector v) {
    return sqrt(v.x*v.x + v.y*v.y);
  }
}
