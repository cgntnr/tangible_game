import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.List;
import java.util.Collections;


final class Hough {


  List<PVector> hough(PImage edgeImg, int nLines) {

    float discretizationStepsPhi = 0.03f;     
    float discretizationStepsR = 2.5f;                      
    int minVotes=200;          // chosing various minvotes values
    // the value 50 does not work well with local max

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (float phi = 0; phi <= Math.PI; phi+= discretizationStepsPhi) {
            float r = (float)(x*Math.cos(phi) + y*Math.sin(phi));
            int accPhi = Math.round(phi/discretizationStepsPhi);
            int accR = Math.round(r/discretizationStepsR+0.5f*rDim);
            int idx = accPhi*rDim + accR;
            accumulator[idx] ++;
          }
        }
      }
    }

    PImage houghImg = createImage(rDim, phiDim, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    // houghImg.resize(400, 400);
    houghImg.updatePixels();

    int region =10;

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    for (int idx = 0; idx < accumulator.length; idx++) {
      if (accumulator[idx] > minVotes) {
        if (Local_Max(accumulator, idx, 20, rDim, phiDim) ) {
          bestCandidates.add(idx);
        }}

    }
    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    ArrayList<PVector> lines=new ArrayList<PVector>();
    for (int i = 0; i < nLines && i < bestCandidates.size(); i++) {
      int idx = bestCandidates.get(i);
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }

    /*PImage houghImg = createImage(rDim, phiDim, ALPHA);
     for (int i = 0; i < accumulator.length; i++) {
     houghImg.pixels[i] = color(min(255, accumulator[i]));
     }
     houghImg.updatePixels();
     return houghImg;*/
    return lines;
  }

  boolean Local_Max(int[] accumulator, int idx, int region, int rDim, int phiDim) {

    int value_of_index = accumulator[idx];
    int y = (int) (idx / (rDim));
    int x = idx - (y) * (rDim);    
    for (int yi = Math.max(0, y-region); yi < Math.min(y+region, phiDim); yi++) {
      for (int xi = Math.max(0, x-region); xi < Math.min(x+region, rDim); xi++) {
        int tempIdx = yi*rDim + xi;
        if (accumulator[tempIdx] > value_of_index) {
          return false;
        }
      }
    }
    return true;
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
}
