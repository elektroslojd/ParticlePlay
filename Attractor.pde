
class Attractor extends Node {
  
  public static final int PASSIVE = 0;
  public static final int ATTRACT = 1;
  public static final int REPEL = 2;
  
  
  public int mode = ATTRACT;
  
  private color fillColor = color(0);
  private color strokeColor = color(0);

  Attractor(float theX, float theY) {
    super(theX, theY);
  }


  void act(Node node) {
    switch(mode) {
      case ATTRACT: 
        attract(node);
        break;
      case REPEL: 
        repel(node);
        break;  
    }
  }

  void attract(Node node) {
    // calculate distance
    float dx = x - node.x;
    float dy = y - node.y;
    float d = PApplet.mag(dx, dy);

    if (d > 0 && d < radius) {
      // calculate force
      float s = d/radius;
      float f = 1 / pow(s, 0.5) - 1;
      f = f / radius;
      
      // apply force to node velocity
      node.velocity.x += dx * f;
      node.velocity.y += dy * f;
    }
  }
  
  void repel(Node node) {
    // calculate distance
    float dx = x - node.x;
    float dy = y - node.y;
    float d = PApplet.mag(dx, dy);

    if (d > 0 && d < radius) {
      // calculate force
      float s = d/radius;
      float f = 1 / pow(s, 0.5) - 1;
      f = -1 * f / radius;
      
      // apply force to node velocity
      node.velocity.x += dx * f;
      node.velocity.y += dy * f;
    }
  }
  
  Attractor getClosestNode(List<Attractor> nodes) {
    float minDist = Float.MAX_VALUE;
    Attractor closest = null;
    for(int i = 0; i < nodes.size(); i++) {
      if(this != nodes.get(i)) {
        float dist = dist(this, nodes.get(i));
        if(dist < minDist) {
          minDist = dist;
          closest = nodes.get(i);
        }
      }
    }
    return closest;
  }
  
  Attractor setSize(List<Attractor> theNodes) {
    Attractor closest = getClosestNode(theNodes);
    float d = dist(this, closest);
    float size = d-4;
    if(size > maxNodeSize) {
      size = maxNodeSize;
    }else if(size < minNodeSize) {
      size = minNodeSize;  
    }
    radius = size;
    setDiameter(size);
    
    return closest;
  }
  
  void draw() {
    draw(0);  
  }
  
  void draw(int layer) {
    float size = getSize();
    float dia = size*(layer+1)*circleInc;
    noStroke();
    fill(colors[layer]);
    //ellipse(x, y, dia, dia);
    
    
    if(drawShape) {
      shapeMode(CENTER);
      if(drawShapePerLayer) {
        int shapeSuffix = layer+1;
        if(shapeSuffix > activeShape.getChildCount()) {
          shapeSuffix = 1;
        }
        shape(activeShape.getChild(shapeName+str(shapeSuffix)), 0, 0, dia, dia);
      }else {
        shape(activeShape.getChild(shapeName+str(shapeNameSuffixIndex)), 0, 0, dia, dia);
      }
    }else {
      ellipse(0, 0, dia, dia);
    }
    
  }
  
  
  float getSize() {
    return doResize ? diameter : minNodeSize;  
  }

}