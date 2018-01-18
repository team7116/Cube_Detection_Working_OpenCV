class Blob{
  float minx;
  float miny;
  float maxx;
  float maxy;

  Blob(float x, float y){
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }
  
  float get_first_x(){return minx;}
  float get_first_y(){return miny;}
  float get_sec_x(){return maxx;}
  float get_sec_y(){return maxy;}
  
  float get_sizex(){return maxx-minx;}
  float get_sizey(){return maxy-miny;}
  
  float get_size(){return ((maxx - minx) + (maxy - miny))/2;}

  void show(){
    
    stroke(255, 255, 0);
    fill(255, 50);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);
    
  }

  void add(float x, float y){
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }
  
  float size(){
    return (maxx-minx)*(maxy-miny); 
  }

  boolean isNear(float x, float y){
    
    float cx = (minx + maxx)/2;
    float cy = (miny + maxy)/2;

    float d = distSq(cx, cy, x, y);
    
    if(d < distThreshold*distThreshold){
      return true;
    }else {
      return false;
    }
    
  }
  
}