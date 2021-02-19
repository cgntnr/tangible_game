float rotateValX;
float rotateValY;
float rotateValZ;
float tempX = 0;
float tempY;
float box_size = 400;
float box_height = 10;
float mouvement_speed = 1;
float diameter = 30;
float moverZPos = 21 ; // 21 for sphere_radius + box_height/2

boolean game_on = true;
boolean villainAdded = false;

PVector temp_loc = new PVector(0, 0, 0);
PVector origin = new PVector(0, 0, moverZPos);

PShape eggman;
//PImage img;// see the note below in setup

PGraphics gameSurface;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;

float topViewMoverX;
float topViewMoverY;
float topViewVillainX;
float topViewVillainY;

ImageProcessing imgproc;
Capture cam;

ArrayList<Float> scores = new ArrayList();

Mover mover;
Cylinder shift_mode_cylinder;
ParticleSystem particleSystem;
HScrollbar bar;

void settings() {
  size(800, 800, P3D);
}

void setup() {

  String []args = {"Image processing window"}; 
  String[] cameras = Capture.list();
  cam = new Capture(this, 640, 480, cameras[0]);
  cam.start();
  imgproc = new ImageProcessing(cam);
  PApplet.runSketch(args, imgproc);

  mover = new Mover();

  particleSystem = new ParticleSystem(origin);
  bar = new HScrollbar(400, height - 25, 375, 20);

  gameSurface = createGraphics(width, height-200, P3D);
  topView = createGraphics(200, 200, P2D);
  scoreBoard = createGraphics(150, 150, P2D);
  barChart = createGraphics(375, 150, P2D);

  eggman = loadShape("robotnik.obj");
  //img = loadImage("robotnik.png");
  //eggman.setTexture(img);
  //setTexture omitted by the suggestion of assistants 
  //because for some reason it slowed extremely the game
  noStroke();
}

void drawGame() {

  gameSurface.beginDraw();
  gameSurface.background(255);
  gameSurface.lights();
  gameSurface.translate(width/2, height/2, 0);
  gameSurface.rotateX(PI/2);
  gameSurface.rotateX(rotateValX);
  gameSurface.rotateY(rotateValY);
  gameSurface.noStroke();
  gameSurface.fill(222, 184, 135);
  gameSurface.lights();
  gameSurface.box(box_size, box_size, box_height);

  //villainAdded boolean in order to deal
  //if someone presses shift but decides not to add new villain
  if (particleSystem.game_started && villainAdded) {
    particleSystem.villainCylinder.draw();

    gameSurface.pushMatrix();
    gameSurface.translate(particleSystem.villainCylinder.position.x, particleSystem.villainCylinder.position.y, 40);
    gameSurface.rotateX(PI/2);
    gameSurface.rotateY(mover.location.copy().sub(particleSystem.villainCylinder.position).heading() + PI/2);
    gameSurface.scale(30);
    gameSurface.shape(eggman, 0, 0);
    gameSurface.popMatrix();
  }

  //shift mode off
  if (game_on) {
    mover.update();
    particleSystem.run();
    if (particleSystem.game_started) {
      if (mover.checkCylinderCollision(particleSystem.villainCylinder.position)) {
        mover.collisionEffect(particleSystem.villainCylinder.position);
        particleSystem.removeAllParticles();
        particleSystem.deleteVillain();
        villainAdded = false;
        particleSystem.game_started = false;
        particleSystem.last = particleSystem.total;
      }
    }
    mover.checkEdges();  
    mover.display();
  } else { //shift mode
    particleSystem.total = 0;
    particleSystem.game_started = false;

    float x = mouseX-box_size;
    float y = mouseY-box_size;

    //cylinder used for determining the villain's position in shift mode
    shift_mode_cylinder = new Cylinder(new PVector(x, y));
    shift_mode_cylinder.draw();

    if (mousePressed) {
      if ((mouseX > 200 + (diameter/2) )  && (mouseY > 200 + (diameter/2) )  &&(mouseX < 600 - (diameter/2) )  &&  (mouseY < 600 - ( diameter/2))) {
        if (!checkBallIntersection()) {
          particleSystem.removeAllParticles();
          particleSystem.addVillain(new PVector(x, y));
          villainAdded = true;
        }
      }
    }
    if (villainAdded) {
      particleSystem.villainCylinder.draw();
    }
  }

  gameSurface.endDraw(); 
}

void drawScore() {
  scoreBoard.beginDraw();
  scoreBoard.background(100);
  String total = "Total Score : ";
  String t = "" + particleSystem.total;
  String velocity = "Velocity : ";
  String v = "" + particleSystem.velocityAmount;
  String last = "Last Score : ";
  String l = "" + particleSystem.last;
  textSize(15);
  fill(0);
  scoreBoard.text(total, 10, 10, 300, 30);
  scoreBoard.text(t, 10, 25, 300, 30);
  scoreBoard.text(velocity, 10, 50, 300, 30);
  scoreBoard.text(v, 10, 65, 300, 30);
  scoreBoard.text(last, 10, 90, 300, 30); 
  scoreBoard.text(l, 10, 105, 300, 30);  
  scoreBoard.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(222, 184, 135);
  topViewMoverX = map(mover.location.x, -200, 200, -100, 100);
  topViewMoverY = map(mover.location.y, -200, 200, -100, 100);
  if (particleSystem.game_started && villainAdded) {
    topViewVillainX = map(particleSystem.villainCylinder.position.x, -200, 200, -100, 100);
    topViewVillainY = map(particleSystem.villainCylinder.position.y, -200, 200, -100, 100);
  }

  topView.translate(100, 100);
  topView.pushMatrix();
  if (particleSystem.game_started && villainAdded) {
    topView.fill(50, 0, 0);
    topView.ellipse(topViewVillainX, topViewVillainY, 15, 15);
  }

  topView.noStroke();
  topView.fill(255, 0, 0);
  topView.ellipse(topViewMoverX, topViewMoverY, 15, 15);

  topView.fill(34, 139, 34);
  for (int i=0; i<particleSystem.particles.size(); i++) {
    topView.ellipse(map(particleSystem.particles.get(i).center.x, -200, 200, -100, 100), 
      map(particleSystem.particles.get(i).center.y, -200, 200, -100, 100), 15, 15);
  }
  topView.popMatrix(); 
  topView.endDraw();
}

void drawChart() {
  barChart.beginDraw();
  barChart.background(192);
  if (frameCount % 30 == 1) {
    scores.add(particleSystem.total);
  }
  float width = map(bar.sliderPosition, bar.sliderPositionMax,bar.sliderPositionMin,3, 10);
  for (int i = 0; i < scores.size(); i++) {
    float score = scores.get(i); 
    if (score > 0) {
      barChart.fill(102, 255, 102);
    } else {
      barChart.fill(255, 102, 102);
    }
    barChart.rect(width*i, 100, width, -3*score);
  }

  barChart.endDraw();
} 

void draw() { 
  if (game_on) {
    updateRotation();
  }
  drawChart();
  image(barChart, 400, height - 175);
  drawGame();
  image(gameSurface, 0, 0);
  drawTopView();
  image(topView, 0, height - 200);
  drawScore();
  image(scoreBoard, 225, height - 175);
  bar.update();
  bar.display();
}

void updateRotation() {
  float tempx = imgproc.rotateValues.x;
  float tempy = imgproc.rotateValues.y;
  float tempz = imgproc.rotateValues.z;
  if (!((tempx == 0) && (tempy == 0) && (tempz == 0))) {

    if ((tempx < PI/6) && (tempx > -PI/6)) {
      rotateValX = tempx;
    }

    if ( (tempz < PI/6) && (tempz > -PI/6)) {
      rotateValY = tempz; //this was due to our different naming of axis
    }
  }
}
boolean checkBallIntersection() {
  PVector mouse = new PVector(mouseX-box_size, mouseY-box_size);
  double distance = dist(mouse.x, mouse.y, mover.location.x, mover.location.y); 
  if (distance < mover.sphere_radius + diameter) {
    return true;
  }
  return false;
}

void mouseWheel(MouseEvent event) {
  mouvement_speed = map(event.getCount(), -10, 10, 1, 10);
}

void mouseDragged() {

  //so that dragging won't work in shift mode
  if (game_on && !bar.locked) { 
    if (pmouseY < mouseY) {
      rotateValX -= PI/180 * mouvement_speed;
    } else if (pmouseY > mouseY) {
      rotateValX += PI/180 * mouvement_speed;
    } 
    if (pmouseX > mouseX) {
      rotateValY -= PI/180 * mouvement_speed;
    } else if (pmouseX < mouseX) {
      rotateValY += PI/180 * mouvement_speed;
    }

    if (rotateValX > PI/6) {
      rotateValX = PI/6;
    } 
    if (rotateValX < -PI/6) {
      rotateValX = -PI/6;
    }
    if (rotateValY > PI/6) {
      rotateValY = PI/6;
    } 
    if (rotateValY < -PI/6) {
      rotateValY = -PI/6;
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      tempX = rotateValX;
      tempY = rotateValY;
      temp_loc = mover.location;
      rotateValX = -PI/2;
      rotateValY = 0;
      game_on = false;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      mover.location = temp_loc;
      rotateValX = tempX;
      rotateValY = tempY;
      game_on = true;
      if (villainAdded) {
        particleSystem.game_started = true;
      }
    }
  }
}
