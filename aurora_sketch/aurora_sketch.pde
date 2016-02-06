// NOTES
// * Pixel value
// * Lights blur next to each other (blue light, red light has purple between them)
// * Transparency dims
// * Horizontal movement is nice

// Constants
int GRAD_VERT = 1;
int GRAD_HOR = 2;
float EASING = 0.01;
boolean TEST = false;

// Globals
OPC opc;
float spotX = 200;
float spotXTarget = 200;
float spotY = 200;
float spotYTarget = 200;
float spotR = 200;
float spotRTarget = 200;
float rainbowYOffset = 0;
float rainbowYOffsetTarget = 0;
float rainbowA = 0;
float rainbowATarget = 0;
PImage spot;


// Seup
void setup() {
  // Size
  size(640, 640, P2D);
  //size(640, 640);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  for (int i = 0; i < 10; i++) {
    opc.ledStrip(i * 62, 62, width / 2, height - (i * height / 10.0 + (height / 20.0)), width / 62.0, 0, false);
  }

  // Make the status LED quiet
  opc.setStatusLed(false);
  
  // Get images
  spot = loadImage("spot.png");

  // Reset background
  background(0);
}

void draw() {
  // Reset background
  background(0);
  
  // Lighting
  lighting();

  // Spot 
  spot();

  // Add light lines
  if (TEST) {
    for (int i = 0; i < 10; i++) {
      rectGradient(0, (height / 10) * i - 25, width, height / 11, color(0, 0, 0), color(0, 0, 0, 1), GRAD_VERT);
    }
  }

  // Delay
  //delay(100);
  println(frameRate);
}

// Spot view.  Use image, as drawing ellipses for a radial alpha gradient
// is very intensive for some reason.
void spot() {
  float noiseJitter = 0.0015;
  
  // Noise radius
  spotR = (noise(frameCount * noiseJitter) * width * 1.5) + (width / 2);
  
  // Noise X and Y
  spotX = noise(frameCount * noiseJitter) * width;
  spotY = noise(1 + frameCount * noiseJitter) * height;
  
  // Some helpful values
  float s = spotR / 640;
  
  // Draw/place
  pushMatrix();
  translate(spotX, spotY);
  scale(s);
  image(spot, -320, -320);
  fill(0, 0, 0);
  noStroke();
  
  // Fill space around (top, bottom, left, right)
  rect(width * -10, height * -10, width * 10 * 4, height * 10 - 318);
  rect(width * -10, 318, width * 10 * 4, height * 10);
  rect(width * -10, -322, width * 10 - 318, height * 10);
  rect(318, -322, width * 10, height * 10);
  
  popMatrix();
}

// Rainbow lighting
void lighting() {
  // Determine where and how to go
  if (rainbowYOffsetTarget - rainbowYOffset < 1 && rainbowYOffsetTarget - rainbowYOffset > -1) {
    rainbowYOffsetTarget = random(-60, 60);
  }
  
  // Move to target
  rainbowYOffset += (rainbowYOffsetTarget - rainbowYOffset) * EASING;
  
  // Determine where and how to go
  if (rainbowATarget - rainbowA < 0.001 && rainbowATarget - rainbowA > -0.001) {
    rainbowATarget = random(-0.1, 0.1);
  }
  rainbowA += (rainbowATarget - rainbowA) * EASING;
  
  pushMatrix();
  translate(-50, 0);
  rotate(rainbowA);

  // Rainbow background
  fill(255, 0, 0);
  rect(0, int((height / 5) * -1 + rainbowYOffset), width * 1.5, height / 5);
  rectGradient(0, int((height / 5) * 0 + rainbowYOffset), width * 1.5, height / 5, color(255, 0, 0), color(255, 255, 0), GRAD_VERT);
  rectGradient(0, int((height / 5) * 1 + rainbowYOffset), width * 1.5, height / 5, color(255, 255, 0), color(0, 255, 0), GRAD_VERT);
  rectGradient(0, int((height / 5) * 2 + rainbowYOffset), width * 1.5, height / 5, color(0, 255, 0), color(0, 255, 255), GRAD_VERT);
  rectGradient(0, int((height / 5) * 3 + rainbowYOffset), width * 1.5, height / 5, color(0, 255, 255), color(0, 0, 255), GRAD_VERT);
  rectGradient(0, int((height / 5) * 4 + rainbowYOffset), width * 1.5, height / 5, color(0, 0, 255), color(255, 0, 255), GRAD_VERT);
  fill(255, 0, 255);
  rect(0, int((height / 5) * 5 + rainbowYOffset), width * 1.5, height / 5);
  
  popMatrix();
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


void radGradient(float x, float y, int radius, color c1, color c2) {
  noFill();
  int step = int(radius / 5);
  int start = radius / 2;
    
  for (int r = start; r < radius; r = r + step) {
    float inter = map(r, start, radius, 0, 1);
    color c = lerpColor(c1, c2, inter);
    strokeWeight(step);
    stroke(c);
    ellipse(x, y, r, r);
  }
}