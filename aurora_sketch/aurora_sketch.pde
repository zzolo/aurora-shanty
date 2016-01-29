// NOTES
// * Pixel value
// * Lights blur next to each other (blue light, red light has purple between them)
// * Transparency dims
// * Horizontal movement is nice

// Globals
OPC opc;

// Testing
int num = 60;
int[] x = new int[num];
int[] y = new int[num];


// Seup
void setup() {
  // Size
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

  // Testing
}

void draw() {
  background(0);

  // Testing
  
}