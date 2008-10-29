long totalX = 0;
long totalY = 0;
int avgX = 0;
int avgY = 0;


void setup(){
  Serial.begin(19200);
  delay(2000);
  for(int i = 0; i < 100; i++){
    totalX += analogRead(0);
    delay(10); 
    totalY += analogRead(1);
    delay(10);
  }
  
  avgX = totalX / 100;
  avgY = totalY / 100;  
  
}



void loop(){
   int xaxis = analogRead(0);
   delay(10);
   int yaxis = analogRead(1);
   Serial.print(avgX - xaxis,DEC);
   Serial.print("  ");
   Serial.print(avgY - yaxis,DEC);
   Serial.println();  
   delay(10);
}
