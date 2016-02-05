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
float spotX;
float spotXTarget = 0;
float spotY;
float spotYTarget = 0;
float spotR;
float spotRTarget = 0;
float rainbowYOffset = 0;
float rainbowYOffsetTarget = 0;


// Seup
void setup() {
  // Size
  //size(640, 640, P2D);
  size(640, 640);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  for (int i = 0; i < 10; i++) {
    opc.ledStrip(i * 62, 62, width / 2, height - (i * height / 10.0 + (height / 20.0)), width / 62.0, 0, false);
  }

  // Make the status LED quiet
  opc.setStatusLed(false);

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
}

// Spot view
void spot() {
  int change = 5;
  
  // Determine where and how to go
  if (spotYTarget - spotY < change && spotYTarget - spotY > (change * -1)) {
    //print("changeX");
    spotYTarget = random(-30, height + 30);
  }
  spotY += (spotYTarget - spotY) * EASING * 2;
  
  if (spotXTarget - spotX < change && spotXTarget - spotX > (change * -1)) {
    //print("changeY");
    spotXTarget = random(-30, width + 30);
  }
  spotX += (spotXTarget - spotX) * EASING * 2;
  
  if (spotRTarget - spotR < change && spotRTarget - spotR > (change * -1)) {
    //print("changeR");
    spotRTarget = random(width / 2, width * 4);
  }
  spotR += (spotRTarget - spotR) * EASING * 2;
  
  // Draw
  radGradient(spotX, spotY, int(spotR), color(0, 0, 0, 1), color(0, 0, 0, 255));
}

// Rainbow lighting
void lighting() {
  // Determine where and how to go
  if (rainbowYOffsetTarget - rainbowYOffset < 1 && rainbowYOffsetTarget - rainbowYOffset > -1) {
    rainbowYOffsetTarget = random(-30, 30);
  }
  
  // Move to target
  rainbowYOffset += (rainbowYOffsetTarget - rainbowYOffset) * EASING;

  // Rainbow background
  rectGradient(0, int((height / 5) * 0 + rainbowYOffset), width, height / 5, color(255, 0, 0), color(255, 255, 0), GRAD_VERT);
  rectGradient(0, int((height / 5) * 1 + rainbowYOffset), width, height / 5, color(255, 255, 0), color(0, 255, 0), GRAD_VERT);
  rectGradient(0, int((height / 5) * 2 + rainbowYOffset), width, height / 5, color(0, 255, 0), color(0, 255, 255), GRAD_VERT);
  rectGradient(0, int((height / 5) * 3 + rainbowYOffset), width, height / 5, color(0, 255, 255), color(0, 0, 255), GRAD_VERT);
  rectGradient(0, int((height / 5) * 4 + rainbowYOffset), width, height / 5, color(0, 0, 255), color(255, 0, 255), GRAD_VERT);
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
  for (int r = 0; r < radius; r ++) {
    float inter = map(r, 0, radius, 0, 1);
    color c = lerpColor(c1, c2, inter);
    noFill();
    strokeWeight(2);
    stroke(c);
    ellipse(x, y, r, r);
  }

  stroke(0, 0, 0);
  for (int r = radius; r < height * 3; r ++) {
    ellipse(x, y, r, r);
  }
}