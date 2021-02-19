import java.util.ArrayList; 
import java.util.List; 
import java.util.TreeSet;
import java.util.Arrays;
import java.util.HashMap;


class BlobDetection {

  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    // First pass: label the pixels and store labels' equivalences

    int [] labels = new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();

    int currentLabel = 1;
    color white = color(255, 255, 255);
    color black = color(0, 0, 0);

    for (int i = 0; i < labels.length; i++) {

      int [] neighbours = {0, 0, 0, 0};

      if (i != 0) {
        if (i < input.width) {
          neighbours[3] = labels[i-1];
        } else if (i % input.width == 0) {
          neighbours[1] = labels[i-input.width];
          neighbours[2] = labels[i-input.width + 1];
        } else if (i % input.width == input.width - 1) {
          neighbours[0] = labels[i-input.width-1];
          neighbours[1] = labels[i-input.width];
          neighbours[3] = labels[i-1];
        } else {
          neighbours[0] = labels[i-input.width-1];
          neighbours[1] = labels[i-input.width];
          neighbours[2] = labels[i-input.width + 1];
          neighbours[3] = labels[i-1];
        }
      }

      if (input.pixels[i] == white) {

        if (((neighbours[0] == 0)) && (neighbours[1] == 0) && (neighbours[2] == 0) && (neighbours[3] == 0)) {
          labels[i] = currentLabel;
          TreeSet<Integer> set = new TreeSet<Integer>();
          set.add(currentLabel);
          labelsEquivalences.add(set);
          currentLabel++;
        } else {
          Arrays.sort(neighbours);
          for (int j = 0; j < neighbours.length; j++) {
            if (neighbours[j] != 0) { // after sorting the labels, the first one that is != 0 is the minimum
              labels[i] = neighbours[j];
              break;
            }
          }
          for (int j = 0; j < neighbours.length; j++) {
            for (int k = 0; k < neighbours.length; k++) {
              if ((neighbours[j] != 0) && (neighbours[k] != 0)) {
                labelsEquivalences.get(neighbours[j]-1).addAll(labelsEquivalences.get(neighbours[k]-1));
                labelsEquivalences.get(neighbours[k]-1).addAll(labelsEquivalences.get(neighbours[j]-1));
              }
            }
          }
        }
      }
    }

    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label

    for (int i = 0; i < labels.length; i++) {
      if (input.pixels[i] == white) {
        labels[i] = labelsEquivalences.get(labels[i]-1).first();
      }
    }
    int [] nbr_pixel_for_label = new int[currentLabel];
    nbr_pixel_for_label[0] = 0;
    if (onlyBiggest) {
      for (int i = 0; i < labels.length; i++) {
        if (labels[i] != 0) {
          nbr_pixel_for_label[labels[i]]++;
        }
      }
    }

    int max = nbr_pixel_for_label[0];
    int maxIndex = 0;

    for (int i = 0; i < nbr_pixel_for_label.length; i++) {
      if (nbr_pixel_for_label[i] > max) {
        max = nbr_pixel_for_label[i];
        maxIndex = i;
      }
    }

    HashMap<Integer, Integer> colorMap = new HashMap<Integer, Integer>();
    colorMap.put(0, 0);
    for (int i = 1; i < nbr_pixel_for_label.length; i++) {
      colorMap.put(i, int(random(0, 255)));
    }

    for (int i = 0; i < labels.length; i++) {
      if (onlyBiggest) {
        if (labels[i] == maxIndex) {
          input.pixels[i] = color(51, 255, 51);
        } else {
          input.pixels[i] = black;
        }
      } else {
        int c = colorMap.get(labels[i]);
        input.pixels[i] = color((2*c) % 255, ( 5*c)%255, (7*c)%255);
      }
    }
    return input;
  }
}
