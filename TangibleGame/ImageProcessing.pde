import gab.opencv.*;
import processing.video.*;

class ImageProcessing extends PApplet {

  PImage img1;
  PImage img2;
  PImage img3;
  PImage img4;
  PImage img5;
  PVector rotateValues = new PVector(0,0,0);
  Capture cam;
  //Movie cam;
  OpenCV opencv;
  //threshold bars for previous steps 
  HScrollbar thresholdBar;
  HScrollbar thresholdBar2;

  //initializations
  Hough h = new Hough();
  BlobDetection bd = new BlobDetection();
  QuadGraph qg = new QuadGraph();

  public ImageProcessing(Capture cam) {
    this.cam = cam;
  }

  void settings() {
    size(960, 540);
  }

  void setup() {
    opencv = new OpenCV(this, 960, 540);
    String[] cameras = Capture.list();
    cam = new Capture(this, 640, 480, cameras[0]);
    cam.start();
    
    //needs to be modified for path
    //cam = new Movie(this, "path_to_file"); //this was to test for video
    //cam.frameRate(25);
    //cam.loop();

  }

  void draw() {

    if (cam.available() == true) {
      cam.read();
    }

    img1 = cam.get();
    image(img1, 0, 0);
   
    //calling image processing methods
    img1 = thresholdHSB(img1, 70, 135, 30, 240, 25, 240);
    img1 = gaussianBlur(img1);
    img1 = scharr(img1);
    img1 = thresholdBinary(img1, 100);
    img1 = bd.findConnectedComponents(img1, true);
    
    List<PVector> lines = h.hough(img1, 30);
    draw_Lines_on_img(lines, img1);
    List<PVector> angles = drawAngles(lines, img1.width, img1.height);
    
    for (int i = 0; i < angles.size(); i++) {
      angles.get(i).z = 1;
    }
    
    TwoDThreeD twoToThree = new TwoDThreeD(img1.width, img1.height, 25);
    rotateValues = twoToThree.get3DRotations(angles);
   
  } 
  
  void draw_Lines_on_img(List<PVector> lines, PImage edgeImg) {
    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line=lines.get(idx);
      float r = line.x;
      float phi = line.y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }

  List<PVector> drawAngles(List<PVector> lines, int imgWidth, int imgHeight) {
    int size_toned;
    size_toned= (int)(imgWidth*imgHeight/0.8);
    List<PVector> ANGLES = qg.findBestQuad(lines, imgWidth, imgHeight, size_toned, 0, false);
    for (int i = 0; i < ANGLES.size(); i++) {
      PVector v = ANGLES.get(i);
      fill(100, 24, 5);
      ellipse(v.x, v.y, 25, 25);
    }
    return ANGLES;
  }

  PImage thresholdBinary(PImage img, int threshold) {
    // create a new, initially transparent, result image

    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) > threshold ) {
        result.pixels[i] = color(255, 255, 255);
      } else {    

        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }

  PImage thresholdBinaryInverted(PImage img, int threshold) {
    // create a new, initially transparent, result image

    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) > threshold) {
        result.pixels[i] = color(0, 0, 0);
      } else {    

        result.pixels[i] = color(255, 255, 255);
      }
    }
    return result;
  }

  PImage thresholdSlider(PImage img, int threshold) {
    // create a new, initially transparent, result image

    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) > threshold * thresholdBar.getPos() ) {
        result.pixels[i] = color(255, 255, 255);
      } else {    
        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }

  PImage hueSetting(PImage img) {

    float minHue = 0;
    float maxHue = 0;

    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {

      if (thresholdBar2.getPos() > thresholdBar.getPos()) {

        minHue = 255 * thresholdBar.getPos();
        maxHue = 255 * thresholdBar2.getPos();
      } else {

        minHue = 255 * thresholdBar2.getPos();
        maxHue = 255 * thresholdBar.getPos();
      }

      if (hue(img.pixels[i]) > minHue &&  hue(img.pixels[i]) < maxHue ) {
        result.pixels[i] = img.pixels[i];
      } else {    

        result.pixels[i] = color(0, 0, 0);
      }
    }


    return result;
  }

  PImage scharr(PImage img) {
    float[][] kernelH = {
      { 3, 10, 3}, 
      { 0, 0, 0}, 
      { -3, -10, -3 }
    };

    float[][] kernelV = {
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 }
    };

    PImage result = createImage(img.width, img.height, ALPHA);

    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }

    float max=0;
    float[] buffer = new float[img.width * img.height];

    int kernelSize = 3;
    int half = (kernelSize/2);

    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {

        // Pixels that are to close to the edge are just set to black.
        if (y < half || y >= (img.height - half) || 
          x < half || x >= (img.width - half) ) {

          result.pixels[y * img.width + x] = color(0);
        } else { // If the pixels are "valid", compute the convolution.
          float sumH = 0;
          float sumV = 0;

          // Iterates through all the nearby pixels.
          for (int i = 0; i < kernelSize; i++) {
            for (int j = 0; j < kernelSize; ++j) {
              int offsetI = i - half;
              int offsetJ = j - half;

              sumH += kernelH[i][j] * brightness(img.pixels[(y + offsetI) * img.width + (x + offsetJ)]);
              sumV += kernelV[i][j] * brightness(img.pixels[(y + offsetI) * img.width + (x + offsetJ)]);
            }
          }
          float sum = sqrt(pow(sumH, 2) + pow(sumV, 2));
          if (sum > max) {
            max = sum;
          }

          buffer[y * img.width + x] = sum;
        }
      }
    }
    for (int y = half; y < (img.height - half); y++) { // Skip top and bottom edges 
      for (int x = half; x < (img.width - half); x++) { // Skip left and right
        int val = (int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x] = color(val);
      }
    }

    return result;
  }

  PImage gaussianBlur(PImage img) {
    float[][] gaussKernel = {{ 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};
    float normFactor = 99.f;
    int kernelSize = 3;

    return convolute(img, gaussKernel, kernelSize, normFactor);
  }

  PImage convolute(PImage img, float[][] kernel, int kernelSize, float normFactor) {
    int half = kernelSize/2;

    color black = color(0);

    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);

    // Iterate through all the pixels of the image.
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {

        // Pixels that are to close to the edge are just set to black.
        if (y < half || y >= (img.height - half) || 
          x < half || x >= (img.width - half) ) {

          result.pixels[y * img.width + x] = black;
        } else { // If the pixels are "valid", compute the convolution.
          int sum = 0;

          // Iterates through all the nearby pixels.
          for (int i = 0; i < kernelSize; i++) {
            for (int j = 0; j < kernelSize; ++j) {
              int offsetI = i - half;
              int offsetJ = j - half;

              sum += kernel[i][j] * brightness(img.pixels[(y + offsetI) * img.width + (x + offsetJ)]);
            }
          }

          int v = (int)(sum / normFactor); // Divide by normFactor.
          result.pixels[y * img.width + x] = color(v);
        }
      }
    }

    return result;
  }

  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {

    PImage result = createImage(img.width, img.height, RGB);



    for (int i = 0; i < img.width * img.height; i++) {

      if ((hue(img.pixels[i]) >= minH && hue(img.pixels[i]) <= maxH) && 
        (saturation(img.pixels[i]) >= minS && saturation(img.pixels[i]) <= maxS) && 
        (brightness(img.pixels[i]) >= minB && brightness(img.pixels[i]) <= maxB)) {

        result.pixels[i] = color(255, 255, 255);
      } else {

        result.pixels[i] = color(0, 0, 0);
      }
    }

    return result;
  }


  boolean imagesEqual(PImage img1, PImage img2) {
    if (img1.width != img2.width || img1.height != img2.height)
      return false;
    for (int i = 0; i < img1.width*img1.height; i++)
      //assuming that all the three channels have the same value
      if (red(img1.pixels[i]) != red(img2.pixels[i])) {
        System.out.println("should be" + red(img1.pixels[i]) + "but" + red(img2.pixels[i]) + "at " + i);
        return false;
      }
    return true;
  }
}
