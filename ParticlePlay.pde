
/*
ParticlePlay
Made for the Elektroslöjd-project at KKV Göteborg 2016.
http://www.elektroslojd.kkvelectro.se/
linus@linusnilsson.net

A starting point was this sketch from Generative Design:
http://www.generative-gestaltung.de/M_4_2_01
*/


import generativedesign.*;
import java.util.Calendar;
import java.util.*;
import java.util.ArrayList;
import processing.pdf.*;
import processing.svg.*;
import controlP5.*;
import toxi.geom.*;
import toxi.geom.mesh2d.*;

Voronoi voronoi;
PolygonClipper2D clipper;

ControlP5 cp5;

List<Attractor> nodes;
List<Attractor> myAttractors;
Attractor activeAttractor = null;

PShape activeShape;

int[] particleRoute;
int routeStep;

int xCount = 40;
int yCount = 40;
int minNodeSize = 2;
int maxNodeSize = 50;
int lineMode = 1;
float attractorSizeMultiplier = 1.0;
int circleLayers = 1;
float circleInc = 1.09;
int shapeStartAngle = 0;
boolean doRotateShape = false;
int shapeRotateMode = 0;

int b1, b2, b3, b4;


String imageName = "particle_play";
boolean showHelp = false;
boolean doAttract = false;
boolean doRepel = false;
boolean showAttractors = false;
boolean doVoronoi = false;
boolean doResize = false;
boolean showCircles = true;
boolean showLines = false;
boolean saveOneFrame = false;
boolean doBoundary = true;


float DAMPING = 0.02;

color[] colors = {
  color(75,5,1),
  color(169,59,0),
  color(51,6,54),
  color(102,113,13),
  color(255,165,11)
};


void setup() {  
  size(700, 700); 
  pixelDensity(displayDensity());
  surface.setResizable(true);
  frameRate(30);
  
  
  noStroke();
  background(255); 
  cursor(CROSS);

  //clipper = new SutherlandHodgemanClipper(new Rect(-5,-5,width+10,height+10));
  
  b1 = b2 = 0;
  b3 = width;
  b4 = height;
  
  activeShape = loadShape("shape1.svg");
  activeShape.disableStyle();
  
  nodes = new ArrayList<Attractor>();
  initGrid();

  myAttractors = new ArrayList<Attractor>();
  Attractor myAttractor = new Attractor(0, 0);
  myAttractor.setRadius(600);
  myAttractor.x = width/2;
  myAttractor.y = height/2;
  myAttractors.add(myAttractor);
  
  setupControls();
}

void draw() {
  setBoundarySliders();
  
  if(saveOneFrame) {
    beginRecord(PDF, imageName+"_"+timestamp()+".pdf");
  }
  
  //fill(255);
  //noStroke();
  //rect(0, 0, width, height);
  background(255);
  
  List<Attractor> sizeList = new ArrayList<Attractor>();
  if(doResize) {
    sizeList.addAll(nodes);
  }
  
  for (Attractor node : nodes) {
    if (doAttract) {
      for(Attractor a : myAttractors) {
        a.act(node);
      }
    }
    
    if(doRepel) {
      for(int n = 0; n < nodes.size(); n++) {
        if(node != nodes.get(n)) {
          node.repel(nodes.get(n));
        }
      }
    }
    
    node.update();
    
    if(doResize) {
      node.setSize(nodes);
    }
    
  }
  
  if(showCircles) {
    for(int n=circleLayers-1; n>=0; n--) {
      for (Attractor node : nodes) {
        pushMatrix();
        translate(node.x, node.y);
        if(doRotateShape) {
          float angle = getRotateShapeAngle(node.x, node.y);
          rotate(angle);
        }
        node.draw(n);
        popMatrix();
      }
    }
  }
  
  if(showAttractors) {
    showAttractors();  
  }
  
  if(doVoronoi) {
    drawVoronoi();  
  }

  if(showLines) {
    drawLines();  
  }

  if (saveOneFrame) {
    saveFrame(imageName+"_"+timestamp()+".png");
    endRecord();
    saveOneFrame = false;
  }
  
  if(showHelp) {
    fill(0, 100);
    noStroke();
    rect(0, 0, 400, height);
    cp5.draw();
  }
  
}

float getRotateShapeAngle(float nodeX, float nodeY) {
  float angle = 0;
  if(shapeRotateMode == 1) {
    angle = radians(shapeStartAngle);
  }else if(shapeRotateMode == 2) {
    angle = atan2(mouseY-nodeY, mouseX-nodeX) + radians(shapeStartAngle);
  }else if(shapeRotateMode == 3) {
    Attractor closest = getClosestAttractor(nodeX, nodeY);
    angle = atan2(closest.y-nodeY, closest.x-nodeX) + radians(shapeStartAngle);
  }else if(shapeRotateMode == 4) {
    
  } 
  return angle; 
}

void drawLines() {
  noFill();
  strokeWeight(1);
  
  if(nodes.size() == xCount*yCount) {
    if(lineMode == 1) {
      int i = 0;
      for (int y = 0; y < yCount; y++) {
        stroke(255, (255/yCount)*(y+1), 50);
        beginShape();
        curveVertex(nodes.get(i).x, nodes.get(i).y);
        for (int x = 0; x < xCount; x++) {
          curveVertex(nodes.get(i).x, nodes.get(i).y);
          i++;
        }
        curveVertex(nodes.get(i-1).x, nodes.get(i-1).y);
        endShape();
      }
    }else if(lineMode == 2) {
      int i = 0;
      for (int y = 0; y < xCount; y++) {
        stroke(255, (255/xCount)*(y+1), 50);
        beginShape();
        curveVertex(nodes.get(y).x, nodes.get(y).y);
        for (int x = 0; x < yCount; x++) {
          i = x * xCount + y;
          curveVertex(nodes.get(i).x, nodes.get(i).y);
        }
        curveVertex(nodes.get(i).x, nodes.get(i).y);
        endShape();
      }
    }else if(lineMode == 3) {
      int i = 0;
      int x = 0;
      int y = 0;
      int sub_x, sub_y;
      //println("---");
      while(true) {
        sub_x = x;
        sub_y = y;
        stroke(255, (255/xCount)*(y+1), 50);
        beginShape();
        i = sub_x * xCount + sub_y;
        if(i < nodes.size()) {
          curveVertex(nodes.get(i).x, nodes.get(i).y);
        }
        //println("sub_x="+sub_x+", sub_y="+sub_y);
        while(sub_x >= 0 && sub_y < yCount) {
          i = sub_x * xCount + sub_y;
          sub_x--;
          sub_y++;
          //println(i);
          if(i < nodes.size()) {
            curveVertex(nodes.get(i).x, nodes.get(i).y);
          }
        }
        if(x < xCount-1) {
          x++;
        }else if(y < yCount-1) {
          y++;  
        }else {
          break;  
        }
        if(i < nodes.size()) {
          curveVertex(nodes.get(i).x, nodes.get(i).y);
        }
        endShape();
      }
      //println("===");
    }else if(lineMode == 4) {
      optimizePlotPath();
      int particleRouteLength = nodes.size();
      stroke(255, 0, 50);
      beginShape();
      curveVertex(nodes.get(particleRoute[0]).x, nodes.get(particleRoute[0]).y);
      for (int i = 0; i < particleRouteLength; ++i) {
        Attractor p1 = nodes.get(particleRoute[i]);
        curveVertex(p1.x, p1.y);
      }
      curveVertex(nodes.get(particleRoute[particleRouteLength-1]).x, nodes.get(particleRoute[particleRouteLength-1]).y);
      endShape();
    }
  }
}


// lifted from https://github.com/evil-mad/stipplegen/blob/master/StippleGen/StippleGen.pde 
void optimizePlotPath() {
  int temp;
  // Calculate and show "optimized" plotting path, beneath points.

  Attractor p1;
  int particleRouteLength = nodes.size();

  if (routeStep == 0) {
    particleRoute = new int[particleRouteLength];
    int tempCounter = 0;
    for (int i = 0; i < particleRouteLength; ++i) {
      particleRoute[tempCounter] = i;
      tempCounter++;
    }
  }

  if (routeStep < (particleRouteLength - 2)) {
    // Nearest neighbor ("Simple, Greedy") algorithm path optimization:

    int StopPoint = routeStep + 1000; // 1000 steps per frame displayed; you can edit this number!

    if (StopPoint > (particleRouteLength - 1)) {
      StopPoint = particleRouteLength - 1;
    }

    for (int i = routeStep; i < StopPoint; ++i) {
      p1 = nodes.get(particleRoute[routeStep]);
      int ClosestParticle = 0;
      float  distMin = Float.MAX_VALUE;

      for (int j = routeStep + 1; j < (particleRouteLength - 1); ++j) {
        Attractor p2 = nodes.get(particleRoute[j]);

        float  dx = p1.x - p2.x;
        float  dy = p1.y - p2.y;
        float  distance = (float) (dx*dx+dy*dy);  // Only looking for closest; do not need sqrt factor!

        if (distance < distMin) {
          ClosestParticle = j;
          distMin = distance;
        }
      }

      temp = particleRoute[routeStep + 1];
      // p1 = particles[particleRoute[routeStep + 1]];
      particleRoute[routeStep + 1] = particleRoute[ClosestParticle];
      particleRoute[ClosestParticle] = temp;

      if (routeStep < (particleRouteLength - 1)) {
        routeStep++;
      } else {
        println("Now optimizing plot path" );
      }
    }
  } else {     // Initial routing is complete
    // 2-opt heuristic optimization:
    // Identify a pair of edges that would become shorter by reversing part of the tour.

    for (int i = 0; i < 90000; ++i) {   // 1000 tests per frame; you can edit this number.
      int indexA = floor(random(particleRouteLength - 1));
      int indexB = floor(random(particleRouteLength - 1));

      if (Math.abs(indexA  - indexB) < 2) {
        continue;
      }

      if (indexB < indexA) { // swap A, B.
        temp = indexB;
        indexB = indexA;
        indexA = temp;
      }

      Attractor a0 = nodes.get(particleRoute[indexA]);
      Attractor a1 = nodes.get(particleRoute[indexA + 1]);
      Attractor b0 = nodes.get(particleRoute[indexB]);
      Attractor b1 = nodes.get(particleRoute[indexB + 1]);

      // Original distance:
      float  dx = a0.x - a1.x;
      float  dy = a0.y - a1.y;
      float  distance = (float)(dx*dx+dy*dy);  // Only a comparison; do not need sqrt factor!
      dx = b0.x - b1.x;
      dy = b0.y - b1.y;
      distance += (float)(dx*dx+dy*dy);  //  Only a comparison; do not need sqrt factor!

      // Possible shorter distance?
      dx = a0.x - b0.x;
      dy = a0.y - b0.y;
      float distance2 = (float)(dx*dx+dy*dy);  //  Only a comparison; do not need sqrt factor! 
      dx = a1.x - b1.x;
      dy = a1.y - b1.y;
      distance2 += (float)(dx*dx+dy*dy);  // Only a comparison; do not need sqrt factor! 

      if (distance2 < distance) {
        // Reverse tour between a1 and b0.

        int indexhigh = indexB;
        int indexlow = indexA + 1;

        // println("Shorten!" + frameRate );

        while (indexhigh > indexlow) {
          temp = particleRoute[indexlow];
          particleRoute[indexlow] = particleRoute[indexhigh];
          particleRoute[indexhigh] = temp;

          indexhigh--;
          indexlow++;
        }
      }
    }
  }
}

void updateVoronoi() {
  clipper = new SutherlandHodgemanClipper(new Rect(-5,-5,width+10,height+10));
  voronoi = new Voronoi();
  for(Attractor node : nodes) {
    voronoi.addPoint(new Vec2D(node.x, node.y));
  }
}

void drawVoronoi() {
  updateVoronoi();
  for(Polygon2D polygon : voronoi.getRegions()) {
    polygon = clipper.clipPolygon(polygon);
    strokeWeight(1);
    stroke(100);
    noFill();
    beginShape();
    for(Vec2D v : polygon.vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }
}

void showAttractors() {
  boolean hasOver = false;
  for(Attractor node : myAttractors) {
    noFill();
    boolean over = overCircle((int)node.x, (int)node.y, (int)node.radius);
    if(over) {
      hasOver = true;
      activeAttractor = node;
      stroke(255,0,0);
    }else {
      if(node.mode == Attractor.ATTRACT) {
        stroke(0,255,0);
      }else if(node.mode == Attractor.REPEL) {
        stroke(0,0,255);
      }else {
        stroke(0,0,0);  
      }
        
    }
    ellipse(node.x, node.y, node.radius, node.radius);
  }
  if(hasOver) {
    moveAttractor();
  }else {
    activeAttractor = null;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void deleteAttractor() {
  if(activeAttractor != null) {
    for(Attractor node : myAttractors) {
      if(node == activeAttractor) {
        myAttractors.remove(node);
        break;
      }
    }
  }
}

void moveAttractor() {
  if(activeAttractor != null && mousePressed && mouseButton == LEFT) {
    activeAttractor.x = mouseX;
    activeAttractor.y = mouseY;
    println("mousePressed: mouseX="+mouseX+", mouseY="+mouseY);
  }
}

void setAttractorMode(int number) {
  if(activeAttractor != null) {
    activeAttractor.mode = number;  
  }
}

/*void setAttractorSize() {
  for(Attractor node : myAttractors) {
    node.setRadius(node.getDiameter() *attractorSizeMultiplier);
  }
}*/

void removeAttractors() {
  activeAttractor = null;
  myAttractors.clear();
}

void setNodesAsAttractors() {
  removeAttractors();
  
  for(Attractor node : nodes) {
    Attractor myAttractor = new Attractor(node.x, node.y);
    myAttractor.setRadius(node.getSize()*attractorSizeMultiplier);
    myAttractors.add(myAttractor);
  }
}

void setAllAttractorsAsAttract() {
  for(Attractor node : myAttractors) {
    node.mode = Attractor.ATTRACT;
  }  
}
void setAllAttractorsAsRepel() {
  for(Attractor node : myAttractors) {
    node.mode = Attractor.REPEL;
  }  
}
void setAllAttractorsAsPassive() {
  for(Attractor node : myAttractors) {
    node.mode = Attractor.PASSIVE;
  }  
}

void changeAttractorsSize() {
  for(Attractor node : myAttractors) {
    node.setRadius(node.getRadius()*attractorSizeMultiplier);
  }  
}

void centerAttractor(String axis) {
  if(activeAttractor != null) {
    if(axis == "hor") {
      activeAttractor.x = width / 2;
    }else if (axis == "vert") {
      activeAttractor.y = height / 2;
    }
  }
}

Attractor getClosestAttractor(float x, float y) {
  float minDist = Float.MAX_VALUE;
  Attractor closest = null;
  for(Attractor node : myAttractors) {
    float dist = dist(x, y, node.x, node.y);
    if(dist < minDist) {
      minDist = dist;
      closest = node;
    }
  }
  return closest;
}

void initGrid() {
  nodes.clear();
  //int i = 0; 
  println("width="+width+", height="+height+", xCount="+xCount+", yCount="+yCount+", doBoundary="+doBoundary);
  float xWidth = b3-b1;
  float yHeight = b4-b2;
  float xInc = xWidth/((xCount-1 > 0 ? xCount-1 : 1));
  float yInc = yHeight/(yCount-1 > 0 ? yCount-1 : 1);
  float xPad = b1;
  float yPad = b2;
  for (int y = 0; y < yCount; y++) { //<>//
    for (int x = 0; x < xCount; x++) {
      float xPos = x*xInc+xPad;
      float yPos = y*yInc+yPad;
      Attractor node = new Attractor(xPos, yPos);
      if(doBoundary) {
        node.setBoundary(-1, -1, width+1, height+1);
      }else {
        node.setBoundary(-Float.MAX_VALUE, -Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
      }
      node.setDamping(DAMPING);  //// 0.0 - 1.0
      node.setRadius(100);
      nodes.add(node);
      //i++;
    }
  }
  routeStep = 0;
}

void setNodeDamping() {
  if(nodes != null) {
    for(Attractor node : nodes) {
      node.setDamping(DAMPING);  
    }
  }
}
void setNodeRadius() {
  if(nodes != null) {
    for(Attractor node : nodes) {
      node.setRadius(maxNodeSize); 
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(activeAttractor != null) {
    activeAttractor.radius += e;  
  }
}

void mouseReleased() {
  if(activeAttractor == null && showHelp == false) {
    Attractor myAttractor = new Attractor(0, 0);
    myAttractor.radius = 300;
    myAttractor.x = mouseX;
    myAttractor.y = mouseY;
    myAttractors.add(myAttractor);
    println(myAttractors.size());
  }
}

void keyPressed() {
  //println("keyPressed: key = "+key+", keyCode = "+keyCode);
  if (key=='h' || key=='H') {
    showHelp = !showHelp;
  }
  if (key=='r' || key=='R') {
    initGrid();
  }
  if (key=='s' || key=='S') {
    saveOneFrame = true;
  }
  if (key=='a' || key=='A') {
    doAttract = !doAttract;
  }
  if (key=='z' || key=='Z') {
    doRepel = !doRepel;
  }
  if (key=='q' || key=='q') {
    showAttractors = !showAttractors;
  }
  if (key=='x' || key=='X') {
    deleteAttractor();
  }
  if (key=='c' || key=='C') {
    Toggle t = (Toggle)cp5.getController("showCircles");
    t.toggle();
  }
  if (key=='l' || key=='L') {
    Toggle t = (Toggle)cp5.getController("showLines");
    t.toggle();
  }
  if (key=='v' || key=='V') {
    doVoronoi = !doVoronoi;
  }
  if (key=='0') {
    setAttractorMode(0);
  }
  if (key=='1') {
    setAttractorMode(1);
  }
  if (key=='2') {
    setAttractorMode(2);
  }
  if(keyCode == LEFT) {
    centerAttractor("hor");
  }
  if(keyCode == DOWN) {
    centerAttractor("vert");
  }
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}