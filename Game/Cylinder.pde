class Cylinder {
  float cylinderRadius = 15;
  float cylinderHeight = 40;
  int cylinderResolution = 40;
  PShape closedCylinder = new PShape();
  PShape close = new PShape();
  PVector position;

  Cylinder(PVector v) {
    float angle; 
    position = v;
    close = createShape();
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];

    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderRadius;
      y[i] = cos(angle) * cylinderRadius;
    }
    closedCylinder = createShape();
    closedCylinder.beginShape(QUAD_STRIP);
    
    closedCylinder.stroke(255, 0, 0);
    closedCylinder.fill(0, 150, 150);


    for (int i = 0; i < x.length; i++) {
      closedCylinder.vertex(x[i], y[i], 0);
      closedCylinder.vertex(x[i], y[i], cylinderHeight);
    }

    
    closedCylinder.endShape();
    close.beginShape(TRIANGLE_FAN);
    close.stroke(0, 200, 200);
    for (int i = 0; i < x.length; i++) {
      close.vertex(0, 0, 5);
      close.vertex(y[i], x[i], 0);
      close.vertex(y[(i+1)%x.length], x[(i+1)%x.length], cylinderHeight );
      close.vertex(0, 0, 0);
      close.vertex(y[i], x[i], cylinderHeight );
      close.vertex(y[(i+1)%x.length], x[(i+1)%x.length], 0);
    } 
    

    close.endShape(TRIANGLE_FAN);
  }

  void draw() {
    gameSurface.pushMatrix();
    gameSurface.stroke(0, 200, 200);
    gameSurface.lights();
    gameSurface.translate(position.x, position.y, 0);
    gameSurface.fill(0, 200, 200);
    gameSurface.shape(closedCylinder);
    gameSurface.shape(close);  
    gameSurface.popMatrix();
    
  }
}
