int ledPin = 6;                // LED connected to digital pin 6
int RF = 3;                    // pin toggle for Right Forward
int RB = 5;                    // pin toggle for Right Backwards
int LF = 2;                    // pin toggle for Left Forward
int LB = 4;                    // pin toggle for Left Backward

int calibration = 0;           //calibrating or not?

int avgMagY = 0;
int avgMagX = 0;

int accAverage[3] = {0,0,0};
int acc[3] = {0,0,0};

int magSensitivity = 4;

int startDelay = 0;


boolean FOODLEFT = false;
boolean FOODRIGHT = false;
boolean FOODUP = false;
boolean FOODDOWN = false;

void setup()                    // run once, when the sketch starts
{
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  for(int i = 0; i < 15; i++){
    delay(750);
    blinkLed();
  }

  randomSeed(analogRead(5));

  // blinkLed();
  pinMode(RF, OUTPUT);
  pinMode(RB, OUTPUT);
  pinMode(LF, OUTPUT);
  pinMode(LB, OUTPUT);
  for(int i = 2; i < 6; i++){   //startup sequence that turns all the motor pins high
    digitalWrite(i, HIGH);
  }    

  blinkLed();

  /* startup sequence to figure out where the bug is magnetically */
  int totalY = 0;  
  int totalX = 0;
  int samples = 20;
  for(int i = 0; i < samples; i++){
    totalY += aR(3);
  }
  blinkLed();

  for(int i = 0; i < samples; i++){
    totalX += aR(4);
  }
  
  for(int j = 0; j < 3; j++){
    int total = 0;
    for(int i = 0; i < samples; i++){
      total += aR(j);
    }
    accAverage[j] = total/samples;
  }
  avgMagX = (totalX/samples);
  avgMagY = (totalY / samples);
  blinkLed();

}

void loop()                    
{
  //function to determine where food is
  int readingY = aR(3);
  int readingX = aR(4);
  foodFind(readingY, readingX);

  int skitterSpeed = 100;
  int runSpeed = 500;
  /*TestPattern */
  if(calibration){  //then calibrate
    blinkLed();
    toggleMotor(LF,500);
    toggleMotor(RF,500);
    toggleMotor(LB,500);
    toggleMotor(RB,500);
  }
  else{
    foodInterest();
    if(run()){
      standardMovement();
    }
    checkForBump();
  }
}




void checkForBump(){
  checkPosition();
  /* Making some comparisons to averages */
  
  //0 is tip up, tip down
  //1 is tilt left, tilt right
  //2 is (if it's more than 100 difference the thing is upside down)
  
  if( abs(acc[0] - accAverage[0]) > 20 ){
    //you have tipped up, or down, presumably because of a collision
    toggleTwoMotors(LB, RB, 1000);
    toggleMotor(RB, 200);
    toggleMotor(LF, 200);
    startDelay = millis() + 2500;
  }
  
  if( abs(acc[2] - accAverage[2]) > 150 ){
    //freak out because you're upside down
    toggleMotor(RF, 100);
    toggleMotor(LF, 100);
    toggleMotor(RB, 100);
    toggleMotor(LB, 100);
    startDelay = millis() + 2500;
  }  
  
}

void checkPosition(){
   for(int i = 0; i < 3; i++){
     acc[i] = aR(i);
   } 
}


void standardMovement(){
  int skitterSpeed = 100;
  int runSpeed = 700;
  
  
  int rand = random(-10, 10);

  /* Set Run and Skitter Variables */

  if( rand < -1 ){
     startDelay = millis() + 2500; 
  }
  /* Change Direction Condition */
  if(rand < 3 && rand > -1){
    toggleMotor(LF, 200);
    toggleMotor(RB, 100);
    startDelay = millis() + 2500;
  }
  
  if(rand > 2 && rand < 6){
    toggleMotor(RF, 200);
    toggleMotor(LB, 100);
    startDelay = millis() + 2500;
  }

  /* Run Condition */
  
   if(rand > 5){
      toggleTwoMotors(LF, RF, runSpeed);
      delay(1000);
      toggleMotor(LF, skitterSpeed);
      toggleMotor(RB, skitterSpeed);
      toggleMotor(RF, skitterSpeed);
      toggleMotor(LB, skitterSpeed);
      toggleMotor(RF, skitterSpeed);
      toggleMotor(LB, skitterSpeed);
      toggleMotor(LF, skitterSpeed);
      toggleMotor(RB, skitterSpeed);
      startDelay = millis() + 5000;
   }
  

}

boolean run(){
  if(millis() > startDelay){
    return true;
  }
  else{
    return false; 
  }
}

void foodInterest(){

  if(FOODUP){
    digitalWrite(ledPin, HIGH);
    toggleTwoMotors(RF, LF, 1500);
    startDelay = millis() + 500;
    FOODUP = false;
  }
  else{
    digitalWrite(ledPin, LOW); 
  }

  if(FOODDOWN){
    digitalWrite(ledPin, HIGH);
    toggleMotor(RF, 200);
    toggleMotor(LB, 200);
    toggleMotor(RF, 200);
    toggleMotor(LB, 200);
    startDelay = millis() + 500;
    FOODDOWN = false;
  }
  else{
    digitalWrite(ledPin, LOW); 
  } 
  if(FOODRIGHT){
    digitalWrite(ledPin, HIGH); 
    toggleMotor(LF, 200);
    toggleMotor(RB, 100);
    startDelay = millis() + 500;
    FOODRIGHT = false;
  }
  else{
    digitalWrite(ledPin, LOW); 
  }

  if(FOODLEFT){
    digitalWrite(ledPin, HIGH); 
    toggleMotor(RF, 200);
    toggleMotor(LB, 100);
    startDelay = millis() + 500;
    FOODLEFT = false;
  }
  else{
    digitalWrite(ledPin, LOW); 
  }



}


void toggleMotor(int motorPin, int time){
  digitalWrite(motorPin, LOW);
  delay(time),
  digitalWrite(motorPin, HIGH);
  delay(250); 
}

void toggleTwoMotors(int motor1, int motor2, int time){
  digitalWrite(motor1, LOW);
  digitalWrite(motor2, LOW);
  delay(time);
  digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
  delay(250);
}

void blinkLed(){
  digitalWrite(ledPin, HIGH);
  delay(100);
  digitalWrite(ledPin, LOW);
}

int aR(int pin){
  int value = analogRead(pin);
  delay(20);
  return value;
}

void foodFind(int readingY, int readingX){
  if(avgMagY - readingY > magSensitivity){
    digitalWrite(ledPin, HIGH); 
    FOODUP = false;
    FOODDOWN = true;
  }
  else{
    FOODDOWN = false;
  }

  if(avgMagX - readingX > magSensitivity){
    FOODLEFT = false;
    FOODRIGHT = true;
  }
  else{
    FOODRIGHT = false; 
  }



  if(readingY - avgMagY >  magSensitivity){
    FOODUP = true;
    FOODDOWN = false;
  }
  else{
    FOODUP = false;
  }


  if(avgMagX - readingX < -1 * magSensitivity){
    FOODRIGHT = false;
    FOODLEFT = true;
  }
  else{
    FOODLEFT = false;
  }

}  




