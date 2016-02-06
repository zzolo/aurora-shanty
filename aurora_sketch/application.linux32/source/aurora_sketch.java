import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.net.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class aurora_sketch extends PApplet {

// NOTES
// * Pixel value
// * Lights blur next to each other (blue light, red light has purple between them)
// * Transparency dims
// * Horizontal movement is nice

// Constants
int GRAD_VERT = 1;
int GRAD_HOR = 2;
float EASING = 0.01f;
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
public void setup() {
  // Size
  
  //size(640, 640);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  for (int i = 0; i < 10; i++) {
    opc.ledStrip(i * 62, 62, width / 2, height - (i * height / 10.0f + (height / 20.0f)), width / 62.0f, 0, false);
  }

  // Make the status LED quiet
  opc.setStatusLed(false);
  
  // Get images
  spot = requestImage("spot.png");

  // Reset background
  background(0);
}

public void draw() {
  // Reset background
  background(0);
  
  // Lighting
  lighting();

  // Spot 
  
  if (spot.width > 0) {
    drawSpot();
  }

  // Add light lines
  if (TEST) {
    for (int i = 0; i < 10; i++) {
      rectGradient(0, (height / 10) * i - 25, width, height / 11, color(0, 0, 0), color(0, 0, 0, 1), GRAD_VERT);
    }
  }

  if (TEST) {
    println(frameRate);
  }
}

// Spot view.  Use image, as drawing ellipses for a radial alpha gradient
// is very intensive for some reason.
public void drawSpot() {
  float noiseJitter = 0.0015f;
  
  // Noise radius
  spotR = (noise(frameCount * noiseJitter) * width * 1.5f) + (width / 2);
  
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
public void lighting() {
  // Determine where and how to go
  if (rainbowYOffsetTarget - rainbowYOffset < 1 && rainbowYOffsetTarget - rainbowYOffset > -1) {
    rainbowYOffsetTarget = random(-60, 60);
  }
  
  // Move to target
  rainbowYOffset += (rainbowYOffsetTarget - rainbowYOffset) * EASING;
  
  // Determine where and how to go
  if (rainbowATarget - rainbowA < 0.001f && rainbowATarget - rainbowA > -0.001f) {
    rainbowATarget = random(-0.1f, 0.1f);
  }
  rainbowA += (rainbowATarget - rainbowA) * EASING;
  
  pushMatrix();
  translate(-50, 0);
  rotate(rainbowA);

  // Rainbow background
  fill(255, 0, 0);
  rect(0, PApplet.parseInt((height / 5) * -1 + rainbowYOffset), width * 1.5f, height / 5);
  rectGradient(0, PApplet.parseInt((height / 5) * 0 + rainbowYOffset), width * 1.5f, height / 5, color(255, 0, 0), color(255, 255, 0), GRAD_VERT);
  rectGradient(0, PApplet.parseInt((height / 5) * 1 + rainbowYOffset), width * 1.5f, height / 5, color(255, 255, 0), color(0, 255, 0), GRAD_VERT);
  rectGradient(0, PApplet.parseInt((height / 5) * 2 + rainbowYOffset), width * 1.5f, height / 5, color(0, 255, 0), color(0, 255, 255), GRAD_VERT);
  rectGradient(0, PApplet.parseInt((height / 5) * 3 + rainbowYOffset), width * 1.5f, height / 5, color(0, 255, 255), color(0, 0, 255), GRAD_VERT);
  rectGradient(0, PApplet.parseInt((height / 5) * 4 + rainbowYOffset), width * 1.5f, height / 5, color(0, 0, 255), color(255, 0, 255), GRAD_VERT);
  fill(255, 0, 255);
  rect(0, PApplet.parseInt((height / 5) * 5 + rainbowYOffset), width * 1.5f, height / 5);
  
  popMatrix();
}

// Create a rectangle gradient
// https://processing.org/examples/lineargradient.html
public void rectGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {
  noFill();

  // Top to bottom gradient
  if (axis == GRAD_VERT) {
    for (int i = y; i <= y + h; i++) {
      float inter = map(i, y, y + h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  // Left to right gradient
  else if (axis == GRAD_HOR) {
    for (int i = x; i <= x + w; i++) {
      float inter = map(i, x, x + w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}


public void radGradient(float x, float y, int radius, int c1, int c2) {
  noFill();
  int step = PApplet.parseInt(radius / 5);
  int start = radius / 2;
    
  for (int r = start; r < radius; r = r + step) {
    float inter = map(r, start, radius, 0, 1);
    int c = lerpColor(c1, c2, inter);
    strokeWeight(step);
    stroke(c);
    ellipse(x, y, r, r);
  }
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC
{
  Socket socket;
  OutputStream output;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    this.enableShowLocations = true;
    // https://groups.google.com/forum/#!topic/fadecandy/AMPRMHGqunE
    registerMethod("draw", this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f),
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing,
        angle, zigzag && (i % 2) == 1);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = 0;          // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = 0;          // Length high byte
    packet[3] = 5;          // Length low byte
    packet[4] = 0x00;       // System ID high byte
    packet[5] = 0x01;       // System ID low byte
    packet[6] = 0x00;       // Command ID high byte
    packet[7] = 0x02;       // Command ID low byte
    packet[8] = firmwareConfig;

    try {
      output.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = 0;          // Channel (reserved)
    header[1] = (byte)0xFF; // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);
    header[3] = (byte)(packetLen & 0xFF);
    header[4] = 0x00;       // System ID high byte
    header[5] = 0x01;       // System ID low byte
    header[6] = 0x00;       // Command ID high byte
    header[7] = 0x01;       // Command ID low byte

    try {
      output.write(header);
      output.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
 
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = 0;  // Channel
      packetData[1] = 0;  // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);
      packetData[3] = (byte)(numBytes & 0xFF);
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = null;
  }

  public void connect()
  {
    // Try to connect to the OPC server. This normally happens automatically in draw()
    try {
      socket = new Socket(host, port);
      socket.setTcpNoDelay(true);
      output = socket.getOutputStream();
      println("Connected to OPC server");
    } catch (ConnectException e) {
      dispose();
    } catch (IOException e) {
      dispose();
    }
    
    sendColorCorrectionPacket();
    sendFirmwareConfigPacket();
  }
}
  public void settings() {  size(640, 640, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "aurora_sketch" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
