
import gab.opencv.*;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.MatOfInt;
import org.opencv.core.Rect;
import org.opencv.core.Size;
import org.opencv.core.Point;
import org.opencv.core.Scalar;
import org.opencv.core.CvType;
import org.opencv.imgproc.Imgproc;

import java.awt.Rectangle;

import processing.video.*;

color trackColor; 

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<find> f = new ArrayList<find>();

boolean search = false;

boolean clicked = false;

boolean effects = true;

float rotation;

int huemin;
int huemax;

int satmin;
int satmax;

int minbri;
int maxbri;

OpenCV opencv;
Mat input;
Mat output;

Capture cam;

int cubeamount = 0;

//============================ADJUSTABLE VALUES===========================

//--==blob related variables==--

//blob's color sensitivity
float threshold = 20;

//blob's distance sensitivity
float distThreshold = 165;

//blob's minimum distance to be considered as a cube
float mindistThreshold = 100;

//global detection color
public int trackred = 255;
public int trackgreen = 255;
public int trackblue = 255;

//--==shape detection related variables==--

//shape's angle sensitivity
public int errmarg = 14;

//shape's color sensitivity
public int colormarg = 40;

//shape's point precision
public float diststep = 1;

//========================================================================

PImage frame;
ArrayList<PVector> points = new ArrayList<PVector>();
Point[] inputpoints;

void setup() {

  size(640, 480);

  trackColor = color(trackred, trackgreen, trackblue);

  textSize(15);
  
  frameRate(30);
  
  cam = new Capture(this, 640, 480, "Microsoft LifeCam Cinema", 30);
  cam.start();
  
  opencv = new OpenCV(this, cam.width, cam.height);
  
  input = OpenCV.imitate(opencv.getColor());
  output = OpenCV.imitate(opencv.getColor());

  huemin = 25;
  huemax = 35;

  satmin = 80;
  satmax = 200;
  
  minbri = 130;
  maxbri = 215;
}


void draw() {
  
  if(cam.available()){
    cam.read();
  }
  
  if(frameCount%5 == 0){
    
    if(effects){
      
      boolean possible = true;
      
      try{
        opencv.loadImage(cam);
      }catch (IndexOutOfBoundsException e){
        possible = false;
      }
      
      if(possible){
        
        effects();
        
        frame = opencv.getOutput();
        
        image(frame, 0, 0);
        
        try{
          inputpoints = (convexHullsOutput.get(0).toArray());
        }catch (IndexOutOfBoundsException e){}
        
        fill(255);
        noStroke();
        
        if(convexHullsOutput.size() > 0){
          
          beginShape();
          
          try{
            for(Point p : inputpoints){
              
              
              float x = (float)p.x;
              float y = (float)p.y;
              
              vertex(x, y);
              
            }
          }catch (NullPointerException e){}
          
          endShape(CLOSE);
          
        }
        
      }
      
    }else {
      
      showimage();
      
    }
    
  }
  
  loadPixels();

  blobs.clear();

  threshold = 80;

  for (int x = 10; x < width - 10; x++) {
    for (int y = 10; y < height - 10; y++) {
      
      int loc = x + y * width;
      color currentColor = pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d < threshold*threshold) {

        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
        
      }
      
    }
  }

  if(frameCount%5 == 0){
    if (search && clicked) {
      
      for (int i = f.size() - 1; i >= 0; i--) {
        
        boolean alive = true;
        
        find part = f.get(i);
        Blob parent;
        
        try{
          parent = blobs.get(part.get_parent());
        }catch(IndexOutOfBoundsException e){
          f.remove(i);
          alive = false;
        }
        
        if(alive){
          
          parent = blobs.get(part.get_parent());
          
          part.get_positions(parent.get_first_x(), parent.get_first_y(), parent.get_sec_x(), parent.get_sec_y());
          
          part.getcenter();
          
          part.get_points();
  
          part.get_shape();
  
          part.get_bottom();
  
          part.show();
        }
        
      }

      for (int i = f.size() - 1; i >= 0; i--) {

        find part = f.get(i);

        if (part.is_square()) {
          try{
            blobs.get(i).show();
          }catch (IndexOutOfBoundsException e) { f.remove(i);}
          //println("Shape #" + (i+1) + " is facing");
          fill(0, 255, 0);
        } else {
          fill(255, 0, 0);
        }
        
        text("Shape #" + (i+1) + " facing: " + part.is_square() + "    orientation: " + part.get_orientation(), 0, (i+1) * 15);
        
      }
    } else {

      for (Blob b : blobs) {
        b.show();
      }
      
      createfinders();
      
    }
  }
  
}


float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}


void showimage(){
  
  loadPixels();
  
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      
      pixels[(i) + (j) * width] = cam.get(i*(cam.width/width), j*(cam.height/height));
      
    }
  }
  
  updatePixels();
  
}

void mousePressed() {

  clicked = !clicked;
  
}



void createfinders(){
  
  search = true;
  
  for(int i = f.size() - 1; i >= 0; i--){
    
    f.remove(i);
    
  }

  for (int i = 0; i < blobs.size(); i++) {
    
    Blob b = blobs.get(i);
    
    if(b.get_sizex() > mindistThreshold && b.get_sizey() > mindistThreshold){
    
      f.add(new find(b.get_first_x(), b.get_first_y(), b.get_sec_x(), b.get_sec_y(), i));
      
    }
  }
  
}


void keyPressed() {

  if(key == BACKSPACE){
    effects = !effects;
    println("Application of effects: " + effects);
  }else if(key == 's'){
    distThreshold -= 5;
    println("Distance Threshold: " + distThreshold);
  }else if(key == 'w'){
    distThreshold += 5;
    println("Distance Threshold: " + distThreshold);
  }else if(key == 'e'){
    errmarg += 2;
    println("Errorr Margin: " + errmarg);
  }else if(key == 'd'){
    errmarg -= 2;
    println("Error Margin: " + errmarg);
  }else if(key == 'r'){
    mindistThreshold += 5;
    println("Minimum Distance Threshold: " + mindistThreshold);
  }else if(key == 'f'){
    mindistThreshold -= 5;
    println("Minimum Distance Threshold: " + mindistThreshold);
  }
  
}