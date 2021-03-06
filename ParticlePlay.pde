
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
import toxi.math.conversion.*;

Voronoi voronoi;
PolygonClipper2D clipper;

ControlP5 cp5;
PGraphics pgHelp;

PrintWriter printWriter;
String pcdHeader = "# .PCD v0.7 - Point Cloud Data file format\nVERSION 0.7\nFIELDS x y z\nSIZE 4 4 4\nTYPE F F F\nCOUNT 1 1 1";
Table csv;

List<Attractor> nodes;
List<Attractor> myAttractors;
List<Attractor> activeAttractors;
Attractor activeAttractor;

PShape attractorShape;
PShape activeShape;
PVector mouseOffset;

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

int zMaterialScale = 12;

String imageName = "particle_play";
String savedTimestamp;
String shapeFileName = "shape1.svg";
String shapeName = "shape";
int shapeNameSuffixIndex = 1;
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
boolean drawShape = false;
boolean drawShapePerLayer = false;
boolean doDampingEnd = true;
boolean useTimestamp = true;

float DAMPING = 0.01;
float DAMPING_END = 0.35;


/*
color[] colors = {
  color(75,5,1),
  color(169,59,0),
  color(51,6,54),
  color(102,113,13),
  color(255,165,11)
};
*/

color[] colors = {
  color(255,255,255),
  color(200,200,200),
  color(150,150,150),
  color(100,100,100),
  color(50,50,50)
};


void setup() {
  size(700, 700); 
  //pixelDensity(displayDensity());
  surface.setResizable(true);
  frameRate(30);
  
  
  noStroke();
  background(255); 
  cursor(CROSS);

  //clipper = new SutherlandHodgemanClipper(new Rect(-5,-5,width+10,height+10));
  
  b1 = b2 = 0;
  b3 = width;
  b4 = height;
  
  activeShape = loadShapeFile(shapeFileName);
  println("shapes in file: "+activeShape.getChildCount());
  activeShape.disableStyle();
  
  nodes = new ArrayList<Attractor>();
  initGrid();

  myAttractors = new ArrayList<Attractor>();
  Attractor myAttractor = new Attractor(0, 0);
  myAttractor.setRadius(600);
  myAttractor.x = width/2;
  myAttractor.y = height/2;
  myAttractors.add(myAttractor);
  
  activeAttractors = new ArrayList<Attractor>();
  
  savedTimestamp = timestamp();
  pgHelp = createGraphics(400, height);
  setupControls();
  
}

void draw() {
  setBoundarySliders();
  
  if(saveOneFrame) {
    beginRecord(SVG, getFileSaveName()+".svg");
  }
  
  //fill(255,10);
  //noStroke();
  //rect(0, 0, width, height);
  background(0);
  
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
    saveFrame(getFileSaveName()+".png");
    endRecord();
    saveOneFrame = false;
  }
  
  
   
  if(showHelp) {
    //fill(0, 100);
    //noStroke();
    //rect(0, 0, 400, height);
    pgHelp.beginDraw();
    pgHelp.background(0, 100);
    pgHelp.noStroke();
    pgHelp.endDraw();
    image(pgHelp, 0, 0);
    cp5.draw();
    cp5.show();
  }else {
    cp5.hide();  
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
    
    if(saveOneFrame) {
      setupCSV();
    }
    
    if(lineMode == 1) {
      int i = 0;
      for (int y = 0; y < yCount; y++) {
        stroke(255, (255/yCount)*(y+1), 50);
        beginShape();
        //addCSVRow(nodes.get(i).x, nodes.get(i).y, 6, 1);
        float z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
        addCSVRow(nodes.get(i).x, nodes.get(i).y, -z, 1);
        curveVertex(nodes.get(i).x, nodes.get(i).y);
        for (int x = 0; x < xCount; x++) {
          curveVertex(nodes.get(i).x, nodes.get(i).y);
          z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
          addCSVRow(nodes.get(i).x, nodes.get(i).y, -z);
          i++;
        }
        curveVertex(nodes.get(i-1).x, nodes.get(i-1).y);
        //addCSVRow(nodes.get(i-1).x, nodes.get(i-1).y, 6);
        endShape();
      }
    }else if(lineMode == 2) {
      int i = 0;
      for (int y = 0; y < xCount; y++) {
        stroke(255, (255/xCount)*(y+1), 50);
        beginShape();
        float z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
        addCSVRow(nodes.get(i).x, nodes.get(i).y, -z, 1);
        curveVertex(nodes.get(y).x, nodes.get(y).y);
        for (int x = 0; x < yCount; x++) {
          i = x * xCount + y;
          curveVertex(nodes.get(i).x, nodes.get(i).y);
          z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
          addCSVRow(nodes.get(i).x, nodes.get(i).y, -z);
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
          float z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
          addCSVRow(nodes.get(i).x, nodes.get(i).y, -z, 1);
        }
        //println("sub_x="+sub_x+", sub_y="+sub_y);
        while(sub_x >= 0 && sub_y < yCount) {
          i = sub_x * xCount + sub_y;
          sub_x--;
          sub_y++;
          //println(i);
          if(i < nodes.size()) {
            curveVertex(nodes.get(i).x, nodes.get(i).y);
            float z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
            addCSVRow(nodes.get(i).x, nodes.get(i).y, -z);
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
          float z = nodes.get(i).getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
          addCSVRow(nodes.get(i).x, nodes.get(i).y, -z);
        }
        endShape();
      }
      //println("===");
    }else if(lineMode == 4) {
      optimizePlotPath();
      int particleRouteLength = nodes.size();
      stroke(255, 0, 50);
      beginShape();
      Attractor p1 = nodes.get(particleRoute[0]);
      float z = p1.getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
      addCSVRow(p1.x, p1.y, -z, 1);
      curveVertex(nodes.get(particleRoute[0]).x, nodes.get(particleRoute[0]).y);
      for (int i = 0; i < particleRouteLength; ++i) {
        p1 = nodes.get(particleRoute[i]);
        curveVertex(p1.x, p1.y);
        z = p1.getSize() / maxNodeSize * getZMaterialScale(zMaterialScale);
        addCSVRow(p1.x, p1.y, -z);
      }
      curveVertex(nodes.get(particleRoute[particleRouteLength-1]).x, nodes.get(particleRoute[particleRouteLength-1]).y);
      endShape();
    }
    
    if(saveOneFrame) {
      saveCSV();
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
      if(!activeAttractors.contains(node)) {
        activeAttractors.add(node);
      }
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
    activeAttractor = activeAttractors.get(activeAttractors.size()-1);
    moveAttractor();
  }else {
    activeAttractors.clear();
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
    if(mouseOffset == null) {
      mouseOffset = new PVector(activeAttractor.x-mouseX, activeAttractor.y-mouseY);  
    }
    activeAttractor.x = mouseX + mouseOffset.x;
    activeAttractor.y = mouseY + mouseOffset.y;
    println("moveAttractor: mouseX="+mouseX+", mouseY="+mouseY);
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
  for (int y = 0; y < yCount; y++) { //<>// //<>//
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
    println("mouseReleased: "+myAttractors.size());
  }else if(mouseOffset != null) {
    mouseOffset = null;
    println("mouseReleased: mouseOffset="+mouseOffset);
  }
}

void keyPressed() {
  //println("keyPressed: key = "+key+", keyCode = "+keyCode);
  if (key=='h' || key=='H') {
    showHelp = !showHelp;
  }else if (key=='r' || key=='R') {
    initGrid();
  }else if (key=='s' || key=='S') {
    saveOneFrame = true;
  }else if (key=='a' || key=='A') {
    if(doAttract && doDampingEnd) {
      DAMPING = DAMPING_END;
      setNodeDamping();
    }
    if(!doAttract) {
      DAMPING = cp5.getController("damping").getValue();
      setNodeDamping();
    }
    doAttract = !doAttract;
  }else if(key == 'z' || key == 'Z') {
    Toggle t = (Toggle)cp5.getController("doDampingEnd");
    t.toggle();
  }else if (key=='b' || key=='B') {
    doRepel = !doRepel;
  }else if (key=='q' || key=='q') {
    showAttractors = !showAttractors;
    activeAttractors.clear();
  }else if (key=='x' || key=='X') {
    deleteAttractor();
  }else if (key=='c' || key=='C') {
    Toggle t = (Toggle)cp5.getController("showCircles");
    t.toggle();
  }else if (key=='l' || key=='L') {
    Toggle t = (Toggle)cp5.getController("showLines");
    t.toggle();
  }else if (key=='k' || key=='K') {
    cycleLineMode(1);
  }else if (key=='0') {
    setAttractorMode(0);
  }else if (key=='v' || key=='V') {
    doVoronoi = !doVoronoi;
  }else if (key=='j' || key=='J') {
    cycleLineMode(-1);
  }else if (key=='1') {
    setAttractorMode(1);
  }else if (key=='2') {
    setAttractorMode(2);
  }else if(keyCode == LEFT) {
    centerAttractor("hor");
  }else if(keyCode == DOWN) {
    centerAttractor("vert");
  }
}

void cycleLineMode(int inc) {
  int index = lineMode + inc;
  int max = cp5.get(RadioButton.class, "lineMode").getArrayValue().length; 
  if(index > max) {
    index = 1;  
  }else if(index < 1) {
    index = max;  
  }
  cp5.get(RadioButton.class, "lineMode").activate(index-1);
}

void setShapeFile(File file) {
  shapeFileName = file.getAbsolutePath();
  activeShape = loadShapeFile(shapeFileName);
  activeShape.disableStyle();
}

void setAttractorFile(File file) {
  println("setAttractorFile");
  shapeFileName = file.getAbsolutePath();
  attractorShape = loadShapeFile(shapeFileName);
  int count = attractorShape.getChildCount();
  println("setAttractorFile: attractorShape.getChildCount()="+attractorShape.getChildCount());
  
  if(count > 0) { 
    for(int i=0; i < count; i++) {
      float[] p = getShapeParams(attractorShape.getChild(i));
      //println(i+" - "+p[0]+":"+p[1]+", w="+p[2]+", h="+p[3]);
      Attractor myAttractor = new Attractor(p[0], p[1]);
      myAttractor.setRadius(p[2]);
      myAttractor.setMode(int(p[3]));
      myAttractors.add(myAttractor);
    }
  }

}

float[] getShapeParams(PShape shape) {
  float[] p;
  try {
    p = shape.getParams();    
  }catch(Exception e) {
    println(e);
    return null;
  }
  
  float pw = p[2];
  float ph = p[3];
  p[0] = (p[0] + pw*0.5);
  p[1] = (p[1] + ph*0.5);
  p[3] = 0;
  color c = shape.getStroke(0);
  if(c == color(0,255,0)) {
    p[3] = 1;
  }else if(c == color(0,0,255)) {
    p[3] = 2;
  }
  return p;
}

PShape loadShapeFile(String file) {
  return loadShape(file).getChild("shapes");
}

void setupCSV() {
  csv = new Table();
  csv.addColumn("x");
  csv.addColumn("y");
  csv.addColumn("z");
  csv.addColumn("n");
}
void addCSVRow(float x, float y, float z) {
  addCSVRow(x, y, z, 0);
}
void addCSVRow(float x, float y, float z, int newLine) {
  if(csv != null) {
    float scale = 1;
    TableRow row = csv.addRow();
    row.setFloat("x", x/scale);
    row.setFloat("y", y/scale);
    row.setFloat("z", z/scale);
    row.setInt("n", newLine);
  }
}
void saveCSV() {
  if(csv != null) {
    saveTable(csv, getFileSaveName()+".csv");
  }
}


void savePointCloudFile() {
  printWriter = createWriter(getFileSaveName()+".pcd");
  printWriter.println(pcdHeader);
  printWriter.println("WIDTH "+str(nodes.size()));
  printWriter.println("HEIGHT 1");
  printWriter.println("VIEWPOINT 0 0 0 1 0 0 0");
  printWriter.println("POINTS "+str(nodes.size()));
  printWriter.println("DATA ascii");
  if(nodes != null) {
    for(Attractor node : nodes) {
      printWriter.println(str(node.x)+" "+str(node.y)+" "+str(node.getSize()));  
    }
  }
  printWriter.flush();
  printWriter.close();
}


float getZMaterialScale(int px) {
  return (float)UnitTranslator.millisToPixels((double)px,96);
}

void updateFileSaveNameLabel() {
  if(cp5.get(Textlabel.class, "fileSaveName") != null) {
    cp5.get(Textlabel.class, "fileSaveName").setText(getFileSaveName());
  }
}
String getFileSaveName() {
  String fileName = cp5.get(Textfield.class,"fileSavePrefix").getText();
  if(useTimestamp) {
    fileName += "_" + timestamp();  
  }
  cp5.get(Textlabel.class, "fileSaveName").setText(fileName);
  return fileName;
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}