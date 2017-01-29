
void setupControls() {
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  int xPos = 15;
  int yPos = 15;
  
  Textarea helpText = cp5.addTextarea("txt")
    .setPosition(xPos,yPos)
    .setSize(200,140)
    //.setFont(createFont("arial",10))
    //.setLineHeight(12)
    .setColor(color(255))
    //.setColorBackground(color(0))
    //.setColorForeground(color(255,100));
    ;
  helpText.setText(
    "Controlls being used: \n"
    +"A = Toggles simulation on/off \n"
    +"R = Reset simulation \n"
    +"S = Save frame \n"
    +"B = Do repel, toggle on/off \n"
    +"Q = show/hide attractors \n"
    +"X = Delete active attractor \n"
    +"C = draw circles, toggle on/off \n"
    +"L = draw lines, toggle on/off \n"
    +"V = draw voronoi, toggle on/off \n"
    +"1 = Set mode to attract for active attractor \n"
    +"2 = Set mode to repel for active attractor \n"
    );
  
  cp5.addNumberbox("xCount")
    .setPosition(xPos, yPos+=140)
    .setSize(100,20)
    .setRange(1, 200)
    .setDirection(Controller.HORIZONTAL)
    .setValue(xCount)
    ;
  
  cp5.addNumberbox("yCount")
    .setPosition(xPos, yPos+=40)
    .setSize(100,20)
    .setRange(1, 200)
    .setDirection(Controller.HORIZONTAL)
    .setValue(yCount)
    ;
  
  cp5.addNumberbox("minNodeSize")
    .setPosition(xPos, yPos+=40)
    .setSize(100,20)
    .setRange(1, 100)
    .setDirection(Controller.HORIZONTAL)
    .setValue(minNodeSize)
    ;  
  
  cp5.addNumberbox("maxNodeSize")
    .setPosition(xPos, yPos+=40)
    .setSize(100,20)
    .setRange(1, 200)
    .setDirection(Controller.HORIZONTAL)
    .setValue(maxNodeSize)
    ;
    
  cp5.addNumberbox("circleLayers")
    .setPosition(xPos, yPos+=40)
    .setSize(100,20)
    .setRange(1, colors.length)
    .setDirection(Controller.HORIZONTAL)
    .setValue(circleLayers)
    ;  
    
  cp5.addSlider("circleInc")
    .setPosition(xPos, yPos+=40)
    .setSize(100,20)
    .setRange(1.01, 10.0)
    .setValue(circleInc)
    ;  
  
  cp5.addSlider("damping")
    .setPosition(xPos, yPos+=30)
    .setSize(100,20)
    .setRange(0.01, 1)
    .setValue(DAMPING)
    ;
    
  cp5.addSlider("DAMPING_END")
    .setPosition(xPos, yPos+=25)
    .setSize(100,20)
    .setRange(0.01, 1)
    .setValue(DAMPING_END)
    .setLabel("Damping End")
    ;
    
  cp5.addToggle("doDampingEnd")
   .setPosition(xPos, yPos+=25)
   .setSize(20,20)
   .setValue(doDampingEnd)
   .setLabel("Use Damping End?")
   ;  
  
  cp5.addToggle("showCircles")
   .setPosition(xPos, yPos+=40)
   .setSize(20,20)
   .setValue(showCircles)
   ; 
     
  cp5.addToggle("showLines")
   .setPosition(xPos, yPos+=40)
   .setSize(20,20)
   .setValue(showLines)
   ;    
     
  cp5.addRadioButton("lineMode")
   .setPosition(xPos,yPos+=35)
   .setSize(15,15)
   //.setColorForeground(color(120))
   //.setColorActive(color(255))
   .setColorLabel(color(255))
   .setItemsPerRow(5)
   .setSpacingColumn(20)
   .addItem("1",1)
   .addItem("2",2)
   .addItem("3",3)
   .addItem("4",4)
   .activate(0)
   .hideLabels()
   ;   
    
  cp5.addToggle("doResize")
   .setPosition(xPos, yPos+=30)
   .setSize(20,20)
   .setValue(doResize)
   ;
  
 cp5.addSlider2D("topLeftBoundary")
   .setPosition(xPos,yPos+=40)
   .setSize(50,50)
   .setMinMax(0,0,width/2,height/2)
   .setValue(0,0)
   .setCaptionLabel("")
   ;
   
  cp5.addSlider2D("bottomRightBoundary")
   .setPosition(xPos+52,yPos)
   .setSize(50,50)
   .setMinMax(width/2,height/2,width,height)
   .setValue(width,height)
   .setCaptionLabel("")
   ; 
   
  cp5.addToggle("doBoundary")
   .setPosition(xPos+110, yPos)
   .setSize(20,20)
   .setValue(doBoundary)
   .setCaptionLabel("Boundary")
   ; 
   
  cp5.addBang("setNodesAsAttractors")
   .setPosition(xPos=240, yPos=15)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Use nodes as attractors")
   ;
   
  cp5.addBang("changeAttractorsSize")
   .setPosition(xPos, yPos+=40)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Change attractors size")
   ;
    
  cp5.addSlider("attractorSizeMultiplier")
    .setPosition(xPos+30, yPos)
    .setSize(100,20)
    .setRange(0.01, 10.0)
    .setValue(attractorSizeMultiplier)
    .setLabel("")
    ;    
    
  cp5.addBang("setAllAttractorsAsAttract")
   .setPosition(xPos, yPos+=40)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Attract")
   ;
   
  cp5.addBang("setAllAttractorsAsRepel")
   .setPosition(xPos+40, yPos)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Repel")
   ; 
   
  cp5.addBang("setAllAttractorsAsPassive")
   .setPosition(xPos+80, yPos)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Passive")
   ;   
   
  cp5.addBang("removeAttractors")
   .setPosition(xPos, yPos+=40)
   .setSize(20, 20)
   .setTriggerEvent(Bang.RELEASE)
   .setLabel("Remove all attractors")
   ;   
  
  cp5.addButton("openAttractorFile")
   .setPosition(xPos, yPos+=40)
   .setSize(100,20)
   .setLabel("Open Attractor File")
   ; 
   
  cp5.addButton("openShapeFile")
   .setPosition(xPos, yPos+=40)
   .setSize(100,20)
   .setLabel("Open Shape File")
   ;
   
  cp5.addToggle("drawShape")
   .setPosition(xPos, yPos+=30)
   .setSize(20,20)
   .setValue(drawShape)
   .setLabel("Shape from file")
   ;
   
   cp5.addToggle("drawShapePerLayer")
   .setPosition(xPos+80, yPos)
   .setSize(20,20)
   .setValue(drawShapePerLayer)
   .setLabel("New each layer")
   ;
   
  cp5.addToggle("doRotateShape")
   .setPosition(xPos, yPos+=40)
   .setSize(20,20)
   .setValue(doRotateShape)
   .setLabel("Rotate shape")
   ;
   
  cp5.addRadioButton("shapeRotateMode")
   .setPosition(xPos,yPos+=40)
   .setSize(15,15)
   .setColorLabel(color(255))
   .setItemsPerRow(5)
   .setSpacingColumn(20)
   .addItem("shapeRotateMode1",1)
   .addItem("shapeRotateMode2",2)
   .addItem("shapeRotateMode3",3)
   .addItem("shapeRotateMode4",4)
   .hideLabels()
   ; 
   
  cp5.addKnob("shapeStartAngle")
   .setPosition(xPos, yPos+=20)
   .setRange(0,359)
   .setValue(shapeStartAngle)
   .setRadius(20)
   .setDragDirection(Knob.HORIZONTAL)
   .setAngleRange(PI*2)
   .setStartAngle(0)
   .setLabel("Shape Start Angle")
   ; 
   
  cp5.addTextfield("fileSavePrefix")
   .setPosition(xPos, yPos+=80)
   .setSize(100,20)
   .setValue(imageName)
   .setAutoClear(false)
   .setLabel("Save Name Prefix")
   ;
   
  cp5.addToggle("useTimestamp")
   .setPosition(xPos, yPos+=40)
   .setSize(20,20)
   .setValue(useTimestamp)
   .setLabel("Use timestamp")
   ; 
   
  cp5.addTextlabel("fileSaveName")
    .setPosition(xPos-3, yPos+=50)
    .setSize(220, 20)
    .setText(getFileSaveName())
    .setColorValue(0xffffff00)
    ; 
    
  cp5.addNumberbox("zMaterialScale")
    .setPosition(xPos, yPos+=25)
    .setSize(100,20)
    .setRange(1, 100)
    .setDirection(Controller.HORIZONTAL)
    .setValue(zMaterialScale)
    ;  
      
}

void controlEvent(ControlEvent theEvent) {
  //println("got a control event from controller with id "+theEvent.getId()+" and controller and name "+theEvent.getName());
  Toggle t;
  
  switch(theEvent.getName()) {
    case("damping"):
      DAMPING = theEvent.getController().getValue();
      setNodeDamping();
      break;
    case("doDampingEnd"):
      if(!doAttract && doDampingEnd) {
        DAMPING = DAMPING_END;
        setNodeDamping();
      }
      break;
    case("xCount"):
      xCount = (int)theEvent.getController().getValue();
      t = (Toggle)cp5.getController("showLines");
      if(t != null) {
        t.setValue(false);
      }
      break;
    case("yCount"):
      yCount = (int)theEvent.getController().getValue();
      t = (Toggle)cp5.getController("showLines");
      if(t != null) {
        t.setValue(false);
      }
      break;
    case("minNodeSize"):
      minNodeSize = (int)theEvent.getController().getValue();
      break;
    case("maxNodeSize"):
      maxNodeSize = (int)theEvent.getController().getValue();
      setNodeRadius();
      break;
    case("circleLayers"):
      circleLayers = (int)theEvent.getController().getValue();
      break;  
    case("circleInc"):
      circleInc = theEvent.getController().getValue();
      break;  
    case("attractorSizeMultiplier"):
      attractorSizeMultiplier = theEvent.getController().getValue();
      //setAttractorSize();
      break;  
    case("lineMode"):
      lineMode = (int)theEvent.getValue();
      //println("lineMode="+lineMode);
      break;
    case("topLeftBoundary"):
      getBoundary();
      //println("topLeftBoundary="+s.getArrayValue()[0]+":"+s.getArrayValue()[1]);
      break;
    case("bottomRightBoundary"):
      getBoundary();
      //println("bottomRightBoundary="+s.getArrayValue()[0]+":"+s.getArrayValue()[1]);
      break;
    case("shapeRotateMode"):
      shapeRotateMode = (int)theEvent.getValue();
      break;
    case("fileSavePrefix"):
      updateFileSaveNameLabel();
      break;
    case("useTimestamp"):
      updateFileSaveNameLabel();
      break;
  }
}

void getBoundary() {
  Slider2D s1 = (Slider2D)cp5.getController("topLeftBoundary");
  Slider2D s2 = (Slider2D)cp5.getController("bottomRightBoundary");
  
  if(s1 != null && s2 != null) {
    b1 = (int)s1.getArrayValue()[0];
    b2 = (int)s1.getArrayValue()[1];
    b3 = (int)s2.getArrayValue()[0];
    b4 = (int)s2.getArrayValue()[1];
  }
}

void openShapeFile() {
  selectInput("Select a file", "setShapeFile");  
}
void openAttractorFile() {
  println("openAttractorFile");
  selectInput("Select a file", "setAttractorFile");  
}

void setBoundarySliders() {
  Slider2D s1 = (Slider2D)cp5.getController("topLeftBoundary");
  Slider2D s2 = (Slider2D)cp5.getController("bottomRightBoundary");
  s1.setMinMax(0,0,width/2,height/2);
  s2.setMinMax(width/2,height/2,width,height);
}