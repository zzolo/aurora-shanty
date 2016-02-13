// NOTES
// * Pixel value
// * Lights blur next to each other (blue light, red light has purple between them)
// * Transparency dims
// * Horizontal movement is nice

// Constants
int GRAD_VERT = 1;
int GRAD_HOR = 2;
boolean TEST = true;
int FR = 25;


// Globals
OPC opc;
AuroraCurve a;

// Color schemes.  This one is from ColorSchemer
color[] colorDistribution1 = {
  color(51, 102, 255),
  color(102, 51, 255),
  color(204, 51, 255),
  color(255, 51, 204),
  color(51, 204, 255),
  color(255, 51, 102),
  color(51, 255, 204),
  color(255, 102, 51),
  color(51, 255, 102),
  color(102, 255, 51),
  color(102, 255, 51),
  color(102, 255, 51),
  color(204, 255, 51)
};
// Just primary colors
color[] colorDistribution2 = {
  color(255, 0, 0),
  color(255, 255, 0),
  color(0, 255, 0),
  color(0, 255, 255),
  color(255, 0, 255),
  color(0, 0, 255)
};
// http://www.color-hex.com/color-palette/6839
color[] colorDistribution3 = {
  color(20,232,30),
  color(20,232,30),
  color(0,234,141),
  color(1,126,213),
  color(181,61,255),
  color(141,0,196)
};
// Custom one
color[] colorDistribution4 = {
  color(102, 255, 51),
  color(51, 255, 102),
  color(51, 204, 255),
  color(61, 245, 0),
  color(46, 184, 0),
  color(51, 102, 255),
  color(138, 0, 184),
  color(184, 0, 245),
  color(102, 51, 255),
  color(255, 102, 51),
  color(255, 51, 102),
  color(255, 51, 204),
  color(204, 51, 255)
};
// https://github.com/FastLED/FastLED/blob/master/colorpalettes.cpp
color[] colorDistribution5 = {
  color(0, 255, 0),
  color(32, 171, 85),
  color(64, 171, 171),
  color(96, 0, 255),
  color(128, 0, 171),
  color(160, 0, 0),
  color(192, 85, 0),
  color(224, 171, 0)
};


// Setup
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
  
  // Set frame rate
  frameRate(FR);
  
  // Start curves
  a = new AuroraCurve();
}


// Main draw
void draw() {
  // Reset background
  background(0);
  
  a.update();
  if (a.isDead()) {
    delay(1000);
    a = new AuroraCurve();
  }
  
  // Add light lines
  if (TEST) {
    for (int i = 0; i < 10; i++) {
      //rectGradient(0, (height / 10) * i + int(height / 20.0) + 5, width, height / 11, color(0, 0, 0, 100), color(0, 0, 0, 1), GRAD_VERT);
    }
  }
  
  // Frame rate
  if (TEST) {
    println(frameRate);
  }
}



// Aurora curve class
class AuroraCurve {
  float[][] c = new float[4][4];
  int lightPrecision = 300;
  AuroraLight[] places = new AuroraLight[lightPrecision];
  color[] colorDistribution = colorDistribution5;
  int[] paletteDistribution = { 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4 };
  float jittering = 0.5;
  int lifespan = int(random(FR * 30, FR * 60));
  int lastleg = int(lifespan * 0.25);
  int step = 0;
  boolean stepForward = true;
  
  AuroraCurve() {
    // Get color set
    getColorDistribution();
    
    // Step which way
    if (random(0, 1) > 0.5) {
      stepForward = false;
    }
    
    // Create base curve
    createCurve();
    
    // Fill places
    fillPlaces();
  }
  
  // Make curve
  void createCurve() {
    c[0][0] = random(width * -0.4, width * 0.1);
    c[0][1] = random(height * 0.4, height * 1.3);
    c[1][0] = random(width * 0.2, width * 0.8);
    c[1][1] = random(height * 0.2, height * 0.8);
    c[2][0] = random(width * 0.2, width * 0.8);
    c[2][1] = random(height * 0.2, height * 0.8);
    c[3][0] = random(width * 0.8, width * 1.3);
    c[3][1] = random(height * -0.1, height * 1.5);
  }
  
  // Fill places
  void fillPlaces() {
    color[] colors = makePalette();
    
    for (int i = 0; i < lightPrecision; i++) {
      float progress = i / float(lightPrecision);
      float x = bezierPoint(c[0][0], c[1][0], c[2][0], c[3][0], progress);
      float y = bezierPoint(c[0][1], c[1][1], c[2][1], c[3][1], progress);
      
      places[i] = new AuroraLight(int(x), int(y), random(0.99, 0.999), colors, i);
    }
  }
  
  // Update
  void update() {
    // Trigger in order for the first round
    if (step < lightPrecision) {
      if (stepForward) {
        places[step].trigger(random(100, 200));
      }
      else {
        places[lightPrecision - step - 1].trigger(random(100, 200));
      }
    }
    // Trigger new one if we are still mostly alive
    else if (lifespan >= lastleg && step % 2 == 0) {
      float progress;
      int place;
      
      // Flow or random
      if (random(0, 1) > 0.6) {
        place = step % lightPrecision;
      }
      else {
        progress = random(0, 1);
        place = int(progress * lightPrecision);
      }
      
      if (places[place] != null) {
        places[place].trigger(random(230, 256));
      }
    }
    
    // Draw
    for (int i = 0; i < lightPrecision; i++) {
      if (places[i] != null) {
        places[i].update();
      }
    }
    
    // Ste a little bit;
    step += 4;
    
    // Die a little bit
    lifespan--;
    
    //drawCurve();
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
  
  // Pick color distribution
  void getColorDistribution() {
    int dist = int(random(1, 6));
    if (dist == 1) { colorDistribution = colorDistribution1; }
    if (dist == 2) { colorDistribution = colorDistribution2; }
    if (dist == 3) { colorDistribution = colorDistribution3; }
    if (dist == 4) { colorDistribution = colorDistribution4; }
    if (dist == 5) { colorDistribution = colorDistribution5; }
  }
  
  // Get random primary color
  color getRandomColor() {
    return colorDistribution[int(random(0, colorDistribution.length))];
  }
  
  // Make palette of colors
  color[] makePalette() {
    int additional = paletteDistribution[int(random(0, paletteDistribution.length))];
    color[] palette = { getRandomColor() };
    for (int a = 0; a <= additional; a++) {
      palette = append(palette, getRandomColor());
    }
    
    return palette;
  }
  
  // For testing, draw curve
  void drawCurve() {
    noFill();
    stroke(255, 255, 255);
    strokeWeight(5);
    bezier(c[0][0], c[0][1], c[1][0], c[1][1], c[2][0], c[2][1], c[3][0], c[3][1]);
  }
}



// Light class
class AuroraLight {
  int x;
  int y;
  int alphaValue = 0;
  float alphaEase = 0.99;
  color[] colors;
  int hUnit;
  int lineWidth = int(random(5, 15));
  
  AuroraLight(int x, int y, float alphaEase, color[] colors, int curveIndex) {
    this.x = x;
    this.y = y;
    this.alphaEase = alphaEase;
    this.colors = colors;
    hUnit = int(noise(curveIndex * 0.01) * 85 + 15);
  }
  
  // Update alpha
  void trigger(float changeAlpha) {
    alphaValue = int(changeAlpha);
  }
  
  // Update/draw
  void update() {
    noFill();
    strokeWeight(lineWidth);
    strokeCap(SQUARE);
    
    // Don't update if no alpha
    if (alphaValue <= 0) {
      return;
    }
    
    // Draw lines
    for (int c = colors.length - 1; c >= 0; c--) {
      // Primary stroke
      stroke(alterAlpha(colors[c], alphaValue * map(c, 0, colors.length - 1, 1, 0.8)));
      line(x, y - hUnit * c, x, y - (hUnit * (c + 1) + 1));
      
      // Secondary stroke
      stroke(alterAlpha(colors[c], alphaValue * 0.2));
      line(x, y - hUnit * (c + 1), x, y - (hUnit * (c + 1.5)));
    }
    
    // Update alpha value
    alphaValue = int(alphaValue * alphaEase);
    if (alphaValue < 0) {
      alphaValue = 0;
    }
  }
  
  color alterAlpha(color inputColor, float alphaChange) {
    if (alphaChange < 0) {
      alphaChange = 0;
    }
    else if (alphaChange > 255) {
      alphaChange = 255;
    }
    
    // Certain colors are weird with a 0 alpha
    if (alphaChange < 1) {
      alphaChange = 1;
    }
    
    return color(red(inputColor), green(inputColor), blue(inputColor), alphaChange);
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