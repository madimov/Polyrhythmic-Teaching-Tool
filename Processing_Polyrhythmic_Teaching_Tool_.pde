// The purpose of this code is to graph the data from Arduino's serial monitor
// into a bar graph. The graph has two horizontal ideal lines, where each ideal line
// represents one of the two components of the polyrhythm. If the data point 
// falls sufficiently close to the ideal, its vertical line turns a “positive” color: 
// BLUE or GREEN (depending on the ideal line in question). If the data point
// doesn't fall close to the ideal, its vertical line turns a "negative" color:
// RED. 

// As a qualitative judgment of polyrhythmic accuracy, you can think:
// BLUE & GREEN = you're doing well!
// RED = you ain't doing so well... but spiral out and keep going!


// GOTTA MAKE SIMPLE CONTROLS FOR DIFFICULTY SETTINGS

// also, statistical analysis could be graphing error.
// this would be noisy, but it could be averaged into a curve.
// the curve should converge as initial learning occurs.
// then maybe wait half an hour and show that there's some remembered learning too.
// could combine these curves from many individuals.

// one group could be the control: after the half hour gap, it's the same tempos!
// another group could be the expt: after the half hour, it's slightly diff tempos!

// thinking out of the box... teaching someone to be *asynchronous* is difficult...
// then again, being asynchronous from 1/2 or 2/3, could simply mean being
// synchronous with something complex, like 37/61...


import processing.serial.*;

// is it important to have everything initialized up *here*? it's good form... do it!
// arrange the initialized variables in the order in which they show up in the code!

Serial myPort; // the serial port
int xPos = 1; // horizontal position of the graph
ArrayList<String> fastdatalist = new ArrayList<String>(); // create array of strings
ArrayList<String> slowdatalist = new ArrayList<String>(); 
ArrayList<String> errorFASTlist = new ArrayList<String>();
ArrayList<String> errorSLOWlist = new ArrayList<String>();
float bslow;
float bfast;
float cslow;
float cfast;
float dfast;
float dslow;
float avgcfast = 800;
float avgcslow = 350;
PFont f;
int yslow = 250; // 1/2->200,2/3->250,3/4->280,4/5->210
int yfast = 400; // 1/2->450,2/3->400,3/4->385,4/5->308

float circleXideal = 800;
float circleYideal = 350;
float circleRadiusideal = 20;

float circleXactual, circleYactual;
float circleRadiusactual = 10;

int timerStart = 0;
int offset;

int mill;
int seconds;

boolean stopped = false;
boolean continued = false;
  
void setup () {
  size(1100, 700); // set window size
  frameRate(10); // prevent slowing of image
  f = createFont("Arial",16,true); // create font for directions

  myPort = new Serial(this, Serial.list()[0], 9600); //only [5] works on my Mac.
  myPort.bufferUntil('\n'); // don't generate serialEvent without newline character.
  background(0); // set inital background as black

  ellipseMode(RADIUS);
  smooth();
}

void draw () { // empty, as everything is done in serialEvent
//background(0);
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n'); // get the ASCII string
  if (inString != null) {
    inString = trim(inString); // trim off any whitespace
    float inByte = float(inString); // convert to float
    inByte = map(inByte, 0, 1023, 0, height); // map to screen height
    int rinByte = round(inByte);
    String realheight = Float.toString(height - rinByte);
    stroke(255);
    line(0, yfast, 500, yfast); // white reference line for ideal fast rhythm
    stroke(255);
    line(0, yslow, 500, yslow); // white reference line for ideal slow rhythm

    // draw green line if value is within 20 pixels of ideal line for fast rhythm:
    if (((height - rinByte) > (yfast - 30)) && (height - rinByte) < (yfast + 30)) {
      stroke(0, 255, 0);
      line(xPos, height, xPos, height - rinByte);
      // categorize this data by adding a digit before the line height, in its string:
      // why is this all necessary if the starting digit doesn't matter below?????
      if (yfast == 450) {
        String fast = "2";
        fast += "," + realheight;
        fastdatalist.add(fast);
      }
      if (yfast == 400) {
          String fast = "3";
          fast += "," + realheight;
          fastdatalist.add(fast);
      }
      if (yfast == 385){
            String fast = "4";
            fast += "," + realheight;
            fastdatalist.add(fast);
      }
      if (yfast == 308){
            String fast = "5";
            fast += "," + realheight;
            fastdatalist.add(fast);
      }
String fastdata[] = fastdatalist.toArray(new String[0]);
    for (int i=0; i < fastdata.length; i++) {
      // takes the second-to-last data point and turns it into a working String
      String tempfast = fastdata[i=fastdata.length - 1];
        String actualfast = tempfast.substring(2, 5);
        float afast = Float.valueOf(actualfast).floatValue();
        bfast = norm(afast, yfast, yfast+20); // decreasing yfast+X ups difficulty
        dfast = norm(afast, yfast,yfast+20); // this is just for data collection
    }
      String errorFAST[] = errorFASTlist.toArray(new String[0]);
      String errorfast = Float.toString(dfast);
      errorFASTlist.add(errorfast);
      saveStrings("fast.csv", errorFAST);
     
  }
    // draw blue line if  value is within 20 pixels from ideal 100 line for slow rhythm:
    if (((height - rinByte) > (yslow - 30)) && (height - rinByte) < (yslow + 30)) { 
      stroke(0, 100, 255);
      line(xPos, height, xPos, height - rinByte);
      // categorize this data by adding a digit before the line height, in its string:
      // why is this all necessary if the starting digit doesn't matter below?????
      if (yslow == 200) {
        String slow = "1";
        slow += "," + realheight;
        slowdatalist.add(slow);
      }
      if (yslow == 250) {
          String slow = "2";
          slow += "," + realheight;
          slowdatalist.add(slow);
      }
      if (yslow == 280) {
            String slow = "3";
            slow += "," + realheight;
            slowdatalist.add(slow);
      }
      if (yslow == 210) {
            String slow = "4";
            slow += "," + realheight;
            slowdatalist.add(slow);
      }
      String slowdata[] = slowdatalist.toArray(new String[0]);
    for (int i=0; i < slowdata.length; i++) {
      // takes the second-to-last data point and turns it into a working String
      String tempslow = slowdata[i=slowdata.length - 1];
        String actualslow = tempslow.substring(2, 5);
        float aslow = Float.valueOf(actualslow).floatValue();
        bslow = norm(aslow, yslow, yslow+20); // decreasing yslow+X ups difficulty
        dslow = norm(aslow, yslow,yslow+20); // this is just for data collection 
      }
      String errorSLOW[] = errorSLOWlist.toArray(new String[0]);
      String errorslow = Float.toString(dslow);
      errorSLOWlist.add(errorslow);
      saveStrings("slow.csv", errorSLOW);
      }
    // draw  a red line if  value is farther than 20 pixels from either ideal line:
    if (((height - rinByte) > (yslow + 30)) && (height - rinByte) < (yfast - 30) ||
      ((height - rinByte) < (yslow - 30)) || ((height - rinByte) > (yfast + 30))) { 
      stroke(200, 0, 0);
      line(xPos, height, xPos, height - inByte);
    }

    // halfway across the screen, go back to the beginning:
    if (xPos >= 500) {
      xPos = 0;
      background(0);
    } else {
      // increment the horizontal position:
      xPos++;
      xPos++;
    }
  }

// the rest of the code focuses on drawing ellipses,
// with distance from center based on distance from ideal.

  float cfast = map(bfast, -2.0, 2.0, 600, 1000);
  float cslow = map(bslow, -2.0, 2.0, 550, 150);

// average values using infinite impulse response:
avgcfast=.9*avgcfast+.1*(float)(cfast);
avgcslow=.9*avgcslow+.1*(float)(cslow);

circleXactual = avgcfast;
circleYactual = avgcslow; 

if (!stopped) {
    mill=(millis()-timerStart);
    if (continued) mill += offset;
    seconds = mill / 1000;
}

//draw opaque rectangle to remove older score:
stroke(255,0,0);
fill(255,0,0);
rect(850, 20, 100, 60);

textFont(f,50);
fill(255);
  text(seconds, 860, 70);
  text("score =", 680, 70);

if (circleCircleIntersect(circleXideal, circleYideal, circleRadiusideal,
circleXactual, circleYactual, circleRadiusactual) == true) {
    stopped = false;
    continued = true;
    timerStart = millis();
    offset = mill;
  } else {
    stopped = true; // pause
  }
  
//draw translucent red ellipse to show severe offset
stroke(255,0,0);
fill(255,0,0, 20);
ellipse(800, 350, 200, 200);

//draw translucent yellow ellipse to show mild offset
stroke(150,150,0);
fill(255,255,0, 20);
ellipse(800, 350, 100, 100);

//draw translucent green ellipse to show negligible offset... !IDEAL!
stroke(0,150,0);
fill(0,255,0, 20);
ellipse(circleXideal, circleYideal, circleRadiusideal, circleRadiusideal);

//draw translucent rectangle to fade older ellipses:
stroke(0);
fill(0,50);
rect(590, 140, 420, 420);

// display directions for offset of each type of polyrhythm:
if ((yslow == 200) && (yfast == 450)) {
textFont(f,25);
fill(0, 100, 255);
text("1 slow",770,575);
text("1 fast",770,140);
fill(0, 255, 0);
text("2 fast",1020,360);
text("2 slow",520,360);
}
else if ((yslow == 250) && (yfast == 400)) {
textFont(f,25);
fill(0, 100, 255);
text("2 slow",770,575);
text("2 fast",770,140);
fill(0, 255, 0);
text("3 fast",1020,360);
text("3 slow",520,360);
}
else if ((yslow == 280) && (yfast == 385)) {
textFont(f,25);
fill(0, 100, 255);
text("3 slow",770,575);
text("3 fast",770,140);
fill(0, 255, 0);
text("4 fast",1020,360);
text("4 slow",520,360);
}
else if ((yslow == 210) && (yfast == 308)) {
textFont(f,25);
fill(0, 100, 255);
text("4 slow",770,575);
text("4 fast",770,140);
fill(0, 255, 0);
text("5 fast",1020,360);
text("5 slow",520,360);
}

// draw ellipses from data:
stroke(0);
fill(255);
ellipse(circleXactual, circleYactual, circleRadiusactual, circleRadiusactual); 

}

// this is a function that returns a boolean based on whether the circles overlap:
boolean circleCircleIntersect(float cxideal, float cyideal, float crideal,
  float cxactual, float cyactual, float cractual) {
  if (dist(cxideal, cyideal, cxactual, cyactual) < crideal + cractual) {
    return true;
  } else {
    return false;
  }
}
