// NOTES
// * Pixel value
// * Lights blur next to each other (blue light, red light has purple between them)
// * Transparency dims
// * Horizontal movement is nice

// Constants
int GRAD_VERT = 1;
int GRAD_HOR = 2;
boolean TEST = false;

// Globals
OPC opc;

  
Aurora a;

// Seup
void setup() {
  // Size
  size(300, 300);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  for (int i = 0; i < 10; i++) {
    opc.ledStrip(i * 62, 62, width / 2, height - (i * height / 10.0 + (height / 20.0)), width / 62.0, 0, false);
  }

  // Make the status LED quiet
  opc.setStatusLed(false);
  
  // Show locations only on test
  opc.showLocations(TEST);
  
  // Set height of lights
  opc.setLightHeight(int(height / 10));
  opc.setLightWidth(int(width / 62) + 6);

  // Reset background
  background(0);
  
  a = new Aurora();
}

void draw() {
  // Reset background
  background(0);
  
  a.update();
  if (a.isDead()) {
    a = new Aurora();
  }
  
  // Add light lines
  if (TEST) {
    for (int i = 0; i < 10; i++) {
      //rectGradient(0, (height / 10) * i - int(height / 20.0), width, height / 11, color(0, 0, 0, 100), color(0, 0, 0, 1), GRAD_VERT);
    }
  }
  
  // Frame rate
  if (TEST) {
    println(frameRate);
  }
  
  //delay(500);
}

// Create aurora class
class Aurora {
  float[][] c = new float[4][4];
  int[] extraLines = new int[0];
  int[] extraLinesEnd = new int[0];
  int extraLineDiff = 0;
  int extraLineEndDiff = 0;
  int extraLineDirection = 1;
  int fullLifespan;
  int lifespan;
  color[] extraColors = new color[0];
  color[] primaryColors = {
    color(255, 0, 0),
    color(255, 255, 0),
    color(255, 0, 255),
    color(0, 255, 0),
    color(0, 255, 255),
    color(0, 0, 255)
  };
  color primaryColor;
  
  Aurora() {
    // Set lifespan
    fullLifespan = int(random(80, 300));
    lifespan = fullLifespan;
    
    // Create base curve
    c[0][0] = random(width / -3, width / 5);
    c[0][1] = random(height / -3, height * (4 / 3));
    c[1][0] = random(width / 3, width * 2 / 3);
    c[1][1] = random(height / 3, height * 2 / 3);
    c[2][0] = random(width / 3, width * 2 / 3);
    c[2][1] = random(height / 3, height * 2 / 3);
    c[3][0] = random(width * 4 / 5, width * (4 / 3));
    c[3][1] = random(height / -3, height * (4 / 3));
    
    // Determine proimary color
    primaryColor = getRandomColor();
    
    // Add extra lines
    int newLines = int(random(0, 18));
    for (int i = 0; i < newLines; i++) {
      addLine();
    }
    
    drawLines();
  }
  
  // Update
  void update() {
    drawLines();
    float progress = map(float(fullLifespan - lifespan), 0.0, float(fullLifespan), 0.0, 1.0);
    
    fill(255);
    noStroke();
    float x = bezierPoint(c[0][0], c[1][0], c[2][0], c[3][0], progress);
    float y = bezierPoint(c[0][1], c[1][1], c[2][1], c[3][1], progress);
    ellipse(x, y, 5, 5);
    
    lifespan -= 1;
  }
  
  // Check if dead
  boolean isDead() {
    if (lifespan <= 0) {
      return true;
    }
    else {
      return false;
    }
  }
  
  // Add new line
  void addLine() {
    // Create new diff then add to array
    extraLineDiff = extraLineDiff + int(random(4, 30));
    extraLines = append(extraLines, extraLineDiff * extraLineDirection);
    
    extraLineEndDiff = extraLineEndDiff + int(random(1, 10));
    extraLinesEnd = append(extraLinesEnd, extraLineEndDiff * extraLineDirection);
    
    // Color
    color c;
    color last = primaryColor;
    
    // Get last color
    if (extraColors.length > 0) {
      last = extraColors[extraColors.length - 1];
    }
    // Get new color
    c = getRandomColor();
    
    // Determine color
    if (random(0, 1) > 0.75) {
      // Assign new color
      extraColors = append(extraColors, last);
    }
    else {
      // Keep old
      extraColors = append(extraColors, last);
    }
    
    // Change direction
    if (extraLineDirection > 0) {
      extraLineDirection = -1;
    }
    else {
      extraLineDirection = 1;
    }
  }
  
  // Draw lines
  void drawLines() {
    noFill();
    
    // Under line
    int opacity = 50;
    strokeCap(PROJECT);
    strokeWeight(100);
    stroke(red(primaryColor), green(primaryColor), blue(primaryColor), opacity);
    bezier(c[0][0], c[0][1], c[1][0], c[1][1], c[2][0], c[2][1], c[3][0], c[3][1]);
    
    for (int i = 0; i < extraLines.length; i++) {
      stroke(red(extraColors[i]), green(extraColors[i]), blue(extraColors[i]), opacity);
      bezier(c[0][0], c[0][1] + extraLinesEnd[i], c[1][0], c[1][1] + extraLines[i], c[2][0], c[2][1] + extraLines[i], c[3][0], c[3][1] + extraLinesEnd[i]);
    }
    
    // Over line
    opacity = 255;
    strokeCap(ROUND);
    strokeWeight(15);
    stroke(red(primaryColor), green(primaryColor), blue(primaryColor), opacity);
    bezier(c[0][0], c[0][1], c[1][0], c[1][1], c[2][0], c[2][1], c[3][0], c[3][1]);
    
    for (int i = 0; i < extraLines.length; i++) {
      stroke(red(extraColors[i]), green(extraColors[i]), blue(extraColors[i]), opacity);
      bezier(c[0][0], c[0][1] + extraLinesEnd[i], c[1][0], c[1][1] + extraLines[i], c[2][0], c[2][1] + extraLines[i], c[3][0], c[3][1] + extraLinesEnd[i]);
    }
  }
  
  // Get random primary color
  color getRandomColor() {
    return primaryColors[int(random(0, primaryColors.length))];
  }
}

// Create a rectangle gradient
// https://processing.org/examples/lineargradient.html
void rectGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();

  // Top to bottom gradient
  if (axis == GRAD_VERT) {
    for (int i = y; i <= y + h; i++) {
      float inter = map(i, y, y + h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  // Left to right gradient
  else if (axis == GRAD_HOR) {
    for (int i = x; i <= x + w; i++) {
      float inter = map(i, x, x + w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}