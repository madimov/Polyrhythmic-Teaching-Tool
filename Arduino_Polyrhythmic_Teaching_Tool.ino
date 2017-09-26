/*
  The circuit:
•	pushbutton attached to pin 2 from +5V
•	pushbutton attached to pin 4 from +5V
•	10K resistor attached to pin 2 from ground
•	10K resistor attached to pin 4 from ground
 
Started with the ButtonStateChange tutorial by Tom Igoe.

The purpose of this code is to measure the time intervals between button presses, for two buttons. 
If the button change is real and not due to noise, this data is sent to the serial monitor. 
Processing accesses this data through Arduino’s Serial Monitor.
 
 */
 
// constants:
  const int pad1Pin = 2;    // the pin that pushbutton 1 is attached to
  const int pad2Pin = 4;    // the pin that pushbutton 2 is attached to
// variables:
  int lastpad1State = LOW;     // previous state of button 1
  int lastpad2State = LOW;     // previous state of button 2 
// long variables, measured in in milliseconds:
  long lastrealTime1 = 0;  // last time a real change was recorded in button 1
  long lastrealTime2 = 0;  // last time a real change was recorded in button 2
  long debounceDelay1 = 200;    // debounce time for button 1
  long debounceDelay2 = 200;    // debounce time for button 2
  
 
void setup() {
  // initialize button pins as inputs:
  pinMode(pad1Pin, INPUT);
  pinMode(pad2Pin, INPUT);
  // initialize serial communication:
  Serial.begin(9600);
}


void loop() {
 
  // read pushbutton 1 input pin:
  int reading1 = digitalRead(pad1Pin);
  // simpler debounce-- ensure the signal is “real” and not due to noise:
  int couldbereal1 = ((millis() - lastrealTime1) > debounceDelay1);
  // print value if reading has changed, could be real, and is high:
  if ((reading1 != lastpad1State) && (couldbereal1) && (reading1 == HIGH)) {
      Serial.println(millis() - lastrealTime1, DEC);
      lastrealTime1 = millis();
  }
  // save current state as last state, for next time through loop:
  lastpad1State = reading1;
  
  // read pushbutton 2 input pin:
  int reading2 = digitalRead(pad2Pin);
  // simpler debounce-- ensure the signal is “real” and not due to noise:
  int couldbereal2 = ((millis() - lastrealTime2) > debounceDelay2);
    // print value if reading has changed, could be real, and is high:
  if ((reading2 != lastpad2State) && (couldbereal2) && (reading2 == HIGH)) {
      Serial.println(millis() - lastrealTime2, DEC);
      lastrealTime2 = millis();
  }
 // save current state as last state, for next time through loop:
  lastpad2State = reading2;
}
