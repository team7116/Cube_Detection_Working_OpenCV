class find{
  
  //blob's position
  PVector pos = new PVector();
  //blob's size
  PVector size = new PVector();
  //blob's center point
  PVector center = new PVector();
  
  //point's line calculation point
  PVector linepos = new PVector();
  
  //line angle
  float angle = -45;
  
  //line's distance from center
  float dist = 0;
  
  //line's detection pixel color
  color pixel;
  
  //line's angle step
  float anglestep = 90;
  
  //amount of points
  int pointlen = 8;
  //current point being placed
  int currentpoint = 0;
  
  //pixle's position in 1D array
  int pixelpos;
  
  //line's current color
  float red;
  float green;
  float blue;
  
  //array of point's position
  PVector[] points = new PVector[pointlen];
  
  //flag if points create a square
  boolean square;
  
  //position for lowest point and it's angle at center
  float lowx, lowy, lowangle;
  
  //flag if shape is not centered
  boolean sided;
  
  //borders position (left -- right -> x pos    up -- down -> y pos)
  float left = 0, right = 0, up = 0, down = 0;
  
  //orientation for shortest path to be facing
  String orientation = "NONE";
  
  
  //associated blob
  int parent;
  
  find(float nx, float ny, float nsizex, float nsizey, int num){
    
    pos.x = nx;
    pos.y = ny;
    size.x = nsizex;
    size.y = nsizey;
    
    
    parent = num;
    
    for(int i = 0; i < pointlen; i++){
      points[i] = new PVector();
    }
    
    getcenter();
    
  }
  
  
  boolean is_square(){return square;}
  String get_orientation(){return orientation;}
  int get_parent(){return parent;}
  
  void get_positions(float nx, float ny, float nsizex, float nsizey){
    
    pos.x = nx;
    pos.y = ny;
    size.x = nsizex;
    size.y = nsizey;
    
  }
  
  void getcenter(){
    
    size.x -= pos.x;
    size.y -= pos.y;
    
    center.x = pos.x + size.x/2;
    center.y = pos.y + size.y/2;
    
    get_track_color();
    
  }
  
  void show(){
    
    if(square){
      pixelsquare(center.x, center.y, 255, 255, 0);
    }else {
      pixelsquare(center.x, center.y, 255, 0, 0);
    }
    
    for(int i = 0; i < pointlen; i++){
      
      pixelsquare(points[i].x, points[i].y, 0, 0, 255);
      
    }
    
    pixelsquare(lowx, lowy, 0, 255, 0);
    
    updatePixels();
    
  }
  
  
  void get_points(){
    
    currentpoint = 0;
    angle = -45;
    anglestep = 90;
    
    if(pixels[int(center.x + int(center.y) * width)] != color(0)){
      
      for(int i = 0; i < pointlen; i++){
        
        if((i) % 4 == 0 && i > 0){
          anglestep /= 2;
          angle = 45 + anglestep;
        }
        
        get_linepos(true);
        
        while(color_bound() && dist < width){
          
          dist += diststep;
          
          get_linepos(true);
          
        }
        
        dist -= diststep;
        
        get_linepos(true);
        
        currentpoint++;
        
        angle += 90;
        angle %= 360;
        dist = 1;
        
        
      }
      
    }
    
  }
  
  
  void get_linepos(boolean editpoint){
    
    linepos.x = center.x + (cos(radians(angle)) * dist);
    linepos.y = center.y + (sin(radians(angle)) * dist);
    
    if(linepos.x < width && linepos.y < height && linepos.x > 0 && linepos.y > 0){
    
      pixelpos = int(floor(linepos.x) + (floor(linepos.y) * width));
      
      pixel = pixels[pixelpos];
      
    }
    
    red = red(pixel);
    green = green(pixel);
    blue = blue(pixel);
    
    if(linepos.x < left || left == 0){
      left = linepos.x;
    }
    
    if(linepos.x > right || right == 0){
      right = linepos.x;
    }
    
    if(linepos.y > down || down == 0){
      down = linepos.y;
    }
    
    if(linepos.y < up || up == 0){
      up = linepos.y;
    }
    
    if(editpoint){
      points[currentpoint].x = linepos.x;
      points[currentpoint].y = linepos.y;
    }
    
  }
  
  
  
  void get_shape(){
      
      boolean[] side = new boolean[4];
      
      //side 0 -> right
      //side 1 -> bottom
      //side 2 -> left
      //side 3 -> right
      
      int ref = 0;
      float refx = 0;
      float refy = 0;
      int correct = 1;
      
      for(int currentside = 0; currentside < 4; currentside++){
        
        correct = 1;
        
        if(currentside == 0){
          refx = points[0].x;
          ref = 0;
        }else if(currentside == 1){
          refy = points[1].y;
          ref = 1;
        }else if(currentside == 2){
          refx = points[2].x;
          ref = 2;
        }else if(currentside == 3){
          refy = points[3].y;
          ref = 3;
        }
        
        for(int i = 0; i < pointlen; i += 1){
          
          if(currentside == 0 || currentside == 3){
            if(points[i].x <= refx + errmarg && points[i].x >= refx - errmarg && i != ref){
              correct++;
            }
          }else if(currentside == 1 || currentside == 2){
            if(points[i].y <= refy + errmarg && points[i].y >= refy - errmarg && i != ref){
              correct++;
            }
          }
          
        }
        
        if(correct == 3){
          side[currentside] = true;
        }else {
          side[currentside] = false;
        }
        
      }
      
      int amount = 0;
      for(int i = 0; i < 4; i++){
        if(side[i]){
          amount++;
        }
      }
      
      if(amount == 4){
        square = true;
      }else {
        square = false;
      }
    
  }
  
  
  void get_bottom(){
    
    angle = 45;
    dist = 1;
    lowangle = angle;
    lowy = -height;
    
    if(pixels[int(center.x + int(center.y) * width)] != color(0)){
      
      while(angle < 135){
        
        get_linepos(false);
        
        while(color_bound() && dist < width){
        
          dist++;
          
          get_linepos(false);
          
        }
        
        dist--;
        get_linepos(false);
        
        if(linepos.y > lowy){
          lowx = linepos.x;
          lowy = linepos.y;
          lowangle = angle;
        }
        
        angle++;
        dist = 1;
        
      }
      
      if(abs(right - lowx) > abs(left - lowx)){
        orientation = "RIGHT";
      }else if(abs(right - lowx) < abs(left - lowx)){
        orientation = "LEFT";
      }else {
        orientation = "CENTER";
      }
      
      if(lowy >= down - errmarg/2 && lowy <= down + errmarg/2 && square){
        orientation = "FACING";
      }
      
    }
    
  }
  
  
  void pixelsquare(float xpos, float ypos, float nr, float ng, float nb){
    
    int squaresize = 5;
    
    for(int i = 0; i < squaresize; i++){
      for(int j = 0; j < squaresize; j++){
        if(int((xpos + i) + ((floor(ypos) + j) * width)) < width*height && int((xpos + i) + ((floor(ypos) + j) * width)) > 0){
          pixels[int((xpos + i) + ((floor(ypos) + j) * width))] = color(nr, ng, nb);
        }
      }
    }
    
  }
  
  
  boolean color_bound(){
    if(red <= trackred + colormarg && red >= trackred - colormarg && green <= trackgreen + colormarg && green >= trackgreen - colormarg && blue <= trackblue + colormarg && blue >= trackblue - colormarg){
      return true;
    }else {
      return false;
    }
  }
  
  
  void get_track_color(){
    
    trackred = int(red(pixels[int(center.x + (floor(center.y) * width))]));
    trackgreen = int(green(pixels[int(center.x + (floor(center.y) * width))]));
    trackblue = int(blue(pixels[int(center.x + (floor(center.y) * width))]));
    
  }
  
  
}