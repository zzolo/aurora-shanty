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


int backgroundValue = 0;

int redValue = 255;
int blueValue = 0;
int greenValue = 0;



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
  background(redValue, greenValue, blueValue);
   //start at red and go to yellow
   if( greenValue<255 && redValue==255 && blueValue==0){
     greenValue++;
    }

    //go from yellow to pure green
    if(greenValue == 255 && redValue>0){
      //redToGreen = false;
     redValue--;
    }

    //go from green to cyan/bluish-green
    if(redValue==0 && greenValue==255 && blueValue<255){

      blueValue++;
    }

    //go from bluish-green to blue
    if(blueValue==255 && greenValue>0){
     greenValue--;
    }
   // go from blue to violet
    if(redValue < 255 && greenValue==0 && blueValue==255){
      redValue++;

    }
    //go from violet to red
  if(redValue == 255 && blueValue>0){
    blueValue--;
  }
}
