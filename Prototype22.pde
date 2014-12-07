//Thank you to those who lent me code and helped me along the way
//Kyle Li for helping with code for Leap Motion pointer
//https://github.com/voidplus/leap-motion-processing for basic Leap Library 
//Lucy theBestTAever 
//Processing.org 

import de.voidplus.leapmotion.*;

//adding images for background design and questionaire  
PImage case1;
PImage case2;
PImage case3;
PImage case4;
PImage case5;
PImage case6;
PImage case7;

//Font for keyboard 
PFont font;

//Variables to start camera and save picture
import processing.video.*;
Capture cam;
int picture; 
PImage img;
boolean takePicture = false;
boolean cameraReady = false;

//Emotions Variables
//A 3 dimentional array to remember the data for all 6 emotions 
//First array represents number of questions
//second array represents the colors R, G, B
//Third array represents the number of choices the user has
float[][][] emotions = new float[6][3][8];
//An array that remembers all 6 choices made by the user 
float[] r = new float[6];
float[] g = new float[6];
float[] b = new float[6];

//Stage variable for sketch sequence
int stage;

//Variables used to draw image captured by camera 
int x;
int y;
int loc; 

float redPixel;
float greenPixel;
float bluePixel;

//Variable used to change millis() back to 0
long lastTime = millis();

//Declare Leap Class
LeapMotion leap;

//Finger Positions for pointers 
PVector finger_position_1;
PVector finger_position_2;
PVector finger_position_3;
PVector finger_position_4;
PVector finger_position_5;

//leap pointer variables
boolean onOption; 
int rolloverColor;
int outsideColor;
int index1;

//Variables for drawing buttons for keyboard
//1-8 (3X3 grid)
float upperLeft_x; 
float upperLeft_y;
float buttonSize; 
float spaceInBetween;

//colors for keyboard
int [] optionColor = {
  #d7a142, 
  #d79243, 
  #d87563, 
  #fa7400, 
  #ff5d63
};

//to keep tracking on which option
int oldNo;

//Timer for the leap pointer
int startTime;
int pauseTime;

//Buttons for taking picture and for starting drawing
PVector picbutton = new PVector(250, 550);

//Finger Positions for drawing tools
//thumb 
float fingerPaintX;
float fingerPaintY;
float fingerPaintPX;
float fingerPaintPY;
float easing = 0.5; //creates effect where if you move leap faster, shapes change size 

//index finger
float fingerPaintX2;
float fingerPaintY2;
float fingerPaintPX2;
float fingerPaintPY2;

//middle finger
float fingerPaintX3;
float fingerPaintY3;
float fingerPaintPX3;
float fingerPaintPY3;

//ring finger
float fingerPaintX4;
float fingerPaintY4;
float fingerPaintPX4;
float fingerPaintPY4;

//pinky finger
float fingerPaintX5;
float fingerPaintY5;
float fingerPaintPX5;
float fingerPaintPY5;

void setup() {
  size(700, 700, OPENGL);
  background(255);
  smooth();

  font = loadFont("AmericanTypewriter-CondensedLight-48.vlw"); //font for keyboard

  //images for background design and questionaire  
  case7 = loadImage("Case7.jpg");
  case1 = loadImage("case1.jpg");
  case2 = loadImage("case2.jpg");
  case3 = loadImage("case3.jpg");
  case4 = loadImage("case4.jpg");
  case5 = loadImage("case5.jpg");
  case6 = loadImage("case6.jpg");

  stage=0; //start stage at 0 

    cameraInitialize(); //start camera
  img = loadImage("test1.jpg"); //reloads picture it took at beginning of sketch


  arrayValues(); //function with 3 dimensional array values

    //Leap
  leap = new LeapMotion(this);
  finger_position_1 = new PVector(0, 0);
  finger_position_2 = new PVector(0, 0);
  finger_position_3 = new PVector(0, 0);
  finger_position_4 = new PVector(0, 0);
  finger_position_5 = new PVector(0, 0);


  //positions for keyboard 
  upperLeft_x = 700/3; 
  upperLeft_y = (700-700/3)/2+200;
  buttonSize = ((700/3)/3)*.90; 
  spaceInBetween = ((700/3)/3)*.10;

  //calculates time for Leap Pointer
  startTime = 0;
  pauseTime = 2000;

  oldNo = 20; //assign a number that is larger than 9 (total options)

  //
  rolloverColor = color(#E1F5C4);
  outsideColor = color(#FF4E50);
  index1 = int(random(optionColor.length));
  onOption = false;
}

void draw() {
  textSize(60);
  textFont(font, 32);

  declareCases(); //calls function with cases
}

void declareCases() {

  println(stage);

  switch(stage) {

  case 0:
    if (!cameraReady) { //starts camera
      cameraReady = true;
    }
    LeapStage0(); //button to take picture, saves picture as test1.jpg to be drawn later
    break;

  case 1:
    image(case1, 0, 0); //background and question 1 
    leapStage1to7(); //function that creates button to change stages, go to next questionn  
    break;

  case 2:
    image(case2, 0, 0); //background and question 2
    leapStage1to7(); //function that creates button to change stages, go to next question
    break;

  case 3:
    image(case3, 0, 0); //background and question 3
    leapStage1to7(); //function that creates button to change stages, go to next question
    break;

  case 4:
    image(case4, 0, 0); //background and question 4
    leapStage1to7(); //function that creates button to change stages, go to next question
    break;

  case 5:
    image(case5, 0, 0); //background and question 5
    leapStage1to7(); //function that creates button to change stages, go to next question
    break;

  case 6:
    image(case6, 0, 0); //background and question 6
    leapStage1to7(); //function that creates button to change stages, go to next question
    break;

  case 7:
    image(case7, 0, 0);  //background instructions
    leapStage7(); //function that creates "Go" Button to start drawing 
    break;

  case 8:
    stageIs8(); //function that calculates color and shape of drawing pixels 

    //drawing image captured by camera 
    //style of drawing based off of data from above function
    stroke(redPixel, greenPixel, bluePixel, 255);
    fill(redPixel, greenPixel, bluePixel, 255);

    x = int(random(img.width));
    y = int(random(img.height));
    loc = x + y * img.width;

    loadPixels();
    redPixel = red(img.pixels[loc]);
    greenPixel = green(img.pixels[loc]);
    bluePixel = blue(img.pixels[loc]);


    //saves drawing when user is finished 
    if (keyPressed && key == ' ') {
      int numbers = 0;
      for (int i = 0; i < 100; i++) {
        numbers =+ i;
      }        
      //uses a time stamp so they all save as different names
      saveFrame("emotionsData_"+day()+hour()+minute()+second()+ ".jpg");
    }
    break;
  }
}

//intialize camera
void cameraInitialize() {
  //Camera
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    //println("There are no cameras available for capture.");
    exit();
  } else {
    // println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }

    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

//3 dimensional array for users input during questionairre 
void arrayValues() {
  //points in total value 

  //when user selects zero 
  emotions[0][0][0] = 0;   //Anxious R
  emotions[1][1][0] = 0;   //Anxious B 
  emotions[1][1][0] = 0;   //isolated G
  emotions[2][1][0] = 0;   //Happy G
  emotions[3][1][0] = 0;   //Peaceful G
  emotions[3][2][0] = 0;   //Peaceful B
  emotions[4][1][0] = 0;   //Connected G
  emotions[5][2][0] = 0;   //Tired B


  //when user input affects R,G,B 
  for (int i = 1; i < 9; i ++) { //make sure to change to 8 for index 0-7
    emotions[0][0][i] = 15*i/2;
    emotions[1][1][1] = 15/2;  //isolated Green
    emotions[2][0][i] = i;     //Happy Red
    emotions[2][1][1] = 10/2;  //Happy Green
    emotions[3][1][1] = 8/2;   //Peaceful Green
    emotions[3][2][1] = 15/2;  //Peaceful Blue
    emotions[4][1][1] = 8/2;   //Connected Green
    emotions[5][2][1] = 15/2;  //Tired Blue
  }

  //when uses input does not affect RGB for that question 
  for (int i = 0; i < 9; i++) {
    emotions[0][1][i] = 0;   //Anxious B
    emotions[0][2][i] = 0;   //Anxious G
    emotions[1][0][i] = 0;   //isolated R
    emotions[2][2][0] = 0;   //Happy B
    emotions[3][0][0] = 0;   //Peaceful R
    emotions[4][0][0] = 0;   //Connected R
    emotions[4][2][0] = 0;   //Connected B
    emotions[5][0][0] = 0;   //Tired R
    emotions[5][1][0] = 0;   //Tired G
  }
}


void updateData(int keyNo) {
  //keys assign values to r, g & b
  if (stage<8 && stage>0) {
    if (keyNo == 0) {
      r[stage-1] = emotions[stage-1][0][0];
      g[stage-1] = emotions[stage-1][1][0];
      b[stage-1] = emotions[stage-1][2][0];
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 1) {
      r[stage-1] = emotions[stage-1][0][1];
      g[stage-1] = emotions[stage-1][1][1];
      b[stage-1] = emotions[stage-1][2][1];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 2) {
      r[stage-1] = emotions[stage-1][0][2];
      g[stage-1] = emotions[stage-1][1][2];
      b[stage-1] = emotions[stage-1][2][2];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 3) {
      r[stage-1] = emotions[stage-1][0][3];
      g[stage-1] = emotions[stage-1][1][3];
      b[stage-1] = emotions[stage-1][2][3];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 4) {
      r[stage-1] = emotions[stage-1][0][4];
      g[stage-1] = emotions[stage-1][1][4];
      b[stage-1] = emotions[stage-1][2][4];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 5) {
      r[stage-1] = emotions[stage-1][0][5];
      g[stage-1] = emotions[stage-1][1][5];
      b[stage-1] = emotions[stage-1][2][5];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 6) {
      r[stage-1] = emotions[stage-1][0][6];
      g[stage-1] = emotions[stage-1][1][6];
      b[stage-1] = emotions[stage-1][2][6];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 7) {
      r[stage-1] = emotions[stage-1][0][7];
      g[stage-1] = emotions[stage-1][1][7];
      b[stage-1] = emotions[stage-1][2][7];      
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 8) {
      r[stage-1] = emotions[stage-1][0][8];
      g[stage-1] = emotions[stage-1][1][8];
      b[stage-1] = emotions[stage-1][2][8];
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    } else if (keyNo == 9) {
      r[stage-1] = emotions[stage-1][0][9];
      g[stage-1] = emotions[stage-1][1][9];
      b[stage-1] = emotions[stage-1][2][9];
      if (stage<8) { //depends what is your final stage
        stage++;
      }
    }
  }
}

void stageIs8() { //function that calculates color and shape of drawing pixels 
  leapStage8();

  //redSum is sum of 3 dimensional arrays depending on the user input on keypad  
  int redSum = 0;
  int greenSum = 0;
  int blueSum = 0;

  for (int i = 0; i < 6; i ++) {
    redSum += r[i]; //dictates how much red is in image
    greenSum += g[i];//dictates how much green is in image
    blueSum += b[i]; //dictates how much blue is in image
  }


  //information from the picture altered by redSum/greenSum/blueSum values 
  redPixel = red(img.pixels[loc]) + redSum; //adds amount of red user input to pixels
  greenPixel = green(img.pixels[loc]) + greenSum;
  //adds amount of green user input to pixels
  bluePixel = blue(img.pixels[loc]) + blueSum;//adds amount of blue user input to pixels


  //dictates size and shape of drawing depnding on user input 
  if (stage == 8) {
    if (redSum == 0) {
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      ellipse(x, y, 25, 25);
    } else if (redSum > 0 && redSum < 13.4) { //DONE
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      for (int i = 0; i < 10; i ++)
        line(x, (y+i), x+i, (y + i));
    } else if (redSum > 13.4 && redSum <= 26.8) {//DONE
      stroke(redPixel, greenPixel, bluePixel, random(0, 50));
      fill(redPixel, greenPixel, bluePixel, random(0, 25));
      strokeWeight(.5);
      for (int i = 0; i < 10; i ++) {
        ellipse(x, y, random(0, 20), random(0, 20));
        for (int j = 0; j < 100; j ++) {
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (redSum > 26.8 && redSum <= 53.6) {//DONE
      for (int i = 0; i < 10; i ++) {
        strokeWeight(.5);
        stroke(redPixel, greenPixel, bluePixel, random(0, 50));
        fill(redPixel, greenPixel, bluePixel, random(0, 15));
        ellipse(x, y, random(0, 25)+1, random(0, 25)+1);
        for (int j = 0; j < 10; j ++) {
          strokeWeight(2);
          stroke(redPixel, greenPixel, bluePixel, random(0, 255));
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (redSum > 53.6 && redSum <= 67) { //DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        fill(redPixel, greenPixel, bluePixel, 100);
        ellipse(x, y, i*random(0, 7), i*random(0, 7));
      }
    } else if (redSum > 67 && redSum <= 80.4) { // DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1.5);
          stroke(redPixel, greenPixel/4, bluePixel/4, 50);
          noFill();
          rect(x, y, i*random(0, 4) + j, i*random(0, 4) + j);
        }
      }
    } else if (redSum > 80.4 && redSum <= 93.8) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1);
          fill(redPixel, greenPixel/4, bluePixel/4, 1);
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 2), j*random(0, 2));
        }
      }
    } else if (redSum > 93.8 && redSum <= 107.2) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel/4, greenPixel/4, bluePixel/4, 10);
          noFill();
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 2), j*random(0, 2));
        }
      }
    } else if (redSum > 107.2 && redSum <= 120.6) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 3), j*random(0, 3));
          ellipse(x, y, j*random(0, 3), j*random(0, 3));
          strokeWeight(1);
          stroke(redPixel, greenPixel/4, bluePixel/4, 1);
          line(x, x*i, y*i, y);
        }
      }
    } else if (redSum > 120.6 && redSum <= 134) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 6), j*random(0, 6));
          stroke(redPixel, greenPixel/4, bluePixel/4, 5);
          ellipse(x, y, j*random(0, 10), j*random(0, 10));
          fill(redPixel, greenPixel, bluePixel, 255);
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
        }
      }
    }

    if (greenSum == 0) {
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      ellipse(x, y, 15, 15);
    } else if (greenSum > 0 && greenSum < 18) { //DONE
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      for (int i = 0; i < 10; i ++)
        line(x, (y+i), x+i, (y + i));
    } else if (greenSum > 18 && greenSum < 36) {//DONE
      stroke(redPixel, greenPixel, bluePixel, random(0, 50));
      fill(redPixel, greenPixel, bluePixel, random(0, 25));
      strokeWeight(.5);
      for (int i = 0; i < 10; i ++) {
        ellipse(x, y, random(0, 20), random(0, 20));
        for (int j = 0; j < 100; j ++) {
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (greenSum > 36 && greenSum < 54) {//DONE
      for (int i = 0; i < 10; i ++) {
        strokeWeight(.5);
        stroke(redPixel, greenPixel, bluePixel, random(0, 50));
        fill(redPixel, greenPixel, bluePixel, random(0, 15));
        ellipse(x, y, random(0, 50), random(0, 50));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(2);
          stroke(redPixel, greenPixel, bluePixel, random(0, 255));
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (greenSum > 54 && greenSum < 71) { //DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        fill(redPixel, greenPixel, bluePixel, 100);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
      }
    } else if (greenSum > 71 && greenSum < 88) { // DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1.5);
          stroke(redPixel, greenPixel/4, bluePixel/4, 50);
          noFill();
          rect(x, y, i*random(0, 2) + j, i*random(0, 2) + j);
        }
      }
    } else if (greenSum > 105 && greenSum < 122) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1);
          fill(redPixel, greenPixel/4, bluePixel/4, 1);
          ellipse(x, y, j*random(0, 3), j*random(0, 3));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 2), j*random(0, 2));
        }
      }
    } else if (greenSum > 122 && greenSum < 140) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel/4, greenPixel/4, bluePixel/4, 10);
          noFill();
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 2), j*random(0, 2));
        }
      }
    } else if (greenSum > 140 && greenSum < 150) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 6), j*random(0, 6));
          ellipse(x, y, j*random(0, 3), j*random(0, 3));
          strokeWeight(1);
          stroke(redPixel, greenPixel/4, bluePixel/4, 1);
          line(x, x*i, y*i, y);
        }
      }
    } else if (greenSum > 150 && greenSum <= 160) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 6), j*random(0, 6));
          stroke(redPixel, greenPixel/4, bluePixel/4, 5);
          ellipse(x, y, j*random(0, 30), j*random(0, 30));
          fill(redPixel, greenPixel, bluePixel, 255);
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
        }
      }
    }
    if (blueSum == 0) {
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      ellipse(x, y, 25, 25);
    } else if (greenSum > 0 && greenSum < 12) { //DONE
      stroke(redPixel, greenPixel, bluePixel, 255);
      fill(redPixel, greenPixel, bluePixel, 255);
      for (int i = 0; i < 10; i ++)
        line(x, (y+i), x+i, (y + i));
    } else if (blueSum  > 12 && blueSum  < 24) {//DONE
      stroke(redPixel, greenPixel, bluePixel, random(0, 60));
      fill(redPixel, greenPixel, bluePixel, random(0, 60));
      strokeWeight(.5);
      for (int i = 0; i < 10; i ++) {
        ellipse(x, y, random(0, 50), random(0, 50));
        for (int j = 0; j < 100; j ++) {
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (blueSum  > 24 && blueSum  < 36) {//DONE
      for (int i = 0; i < 10; i ++) {
        strokeWeight(.5);
        stroke(redPixel, greenPixel, bluePixel, random(0, 50));
        fill(redPixel, greenPixel, bluePixel, random(0, 15));
        ellipse(x, y, random(0, 50), random(0, 50));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(2);
          stroke(redPixel, greenPixel, bluePixel, random(0, 255));
          line(x + i, (y*j), x+i, (y * j));
        }
      }
    } else if (blueSum  > 30 && blueSum  < 40) { //DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        fill(redPixel, greenPixel, bluePixel, 100);
        ellipse(x, y, i*random(0, 7), i*random(0, 7));
      }
    } else if (blueSum  > 42 && blueSum  < 52) { // DONE
      for (int i = 0; i < 10; i ++) {
        noStroke();
        fill(redPixel, greenPixel/4, bluePixel/4, 255);
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1.5);
          stroke(redPixel, greenPixel/4, bluePixel/4, 50);
          noFill();
          rect(x, y, i*random(0, 4) + j, i*random(0, 4) + j);
        }
      }
    } else if (blueSum  > 52 && blueSum  < 62) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          strokeWeight(1);
          fill(redPixel, greenPixel/4, bluePixel/4, 1);
          ellipse(x, y, j*random(0, 10), j*random(0, 10));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
        }
      }
    } else if (blueSum  > 65 && blueSum  < 75) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        ellipse(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel/4, greenPixel/4, bluePixel/4, 10);
          noFill();
          ellipse(x, y, j*random(0, 10), j*random(0, 10));
          fill(redPixel, greenPixel/4, bluePixel/4, 15);
          ellipse(x, y, j*random(0, 2), j*random(0, 2));
        }
      }
    } else if (blueSum  > 85 && blueSum  < 95) { // DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 6), j*random(0, 6));
          ellipse(x, y, j*random(0, 6), j*random(0, 6));
          strokeWeight(1);
          stroke(redPixel, greenPixel/4, bluePixel/4, 1);
          line(x, x*i, y*i, y);
        }
      }
    } else if (blueSum  > 95 && blueSum  <= 105) { //DONE
      for (int i = 0; i < 10; i ++) {
        stroke(redPixel, greenPixel/4, bluePixel/4, 50);
        noFill();
        //rectMode(CENTER);
        rect(x, y, i*random(0, 2), i*random(0, 2));
        for (int j = 0; j < 10; j ++) {
          stroke(redPixel, greenPixel/4, bluePixel/4, 10);
          noFill();
          rect(x, y, j*random(0, 6), j*random(0, 6));
          stroke(redPixel, greenPixel/4, bluePixel/4, 5);
          ellipse(x, y, j*random(0, 60), j*random(0, 60));
          fill(redPixel, greenPixel, bluePixel, 255);
          ellipse(x, y, j*random(0, 5), j*random(0, 5));
        }
      }
    }
  }
}

void leapStage8() { //painting tool for stage 8
  //comments to explain and put in function 
  float targetFingerPaintX = finger_position_1.x;
  fingerPaintX += (targetFingerPaintX - fingerPaintX) * easing;
  float targetFingerPaintY = finger_position_1.y;
  fingerPaintY += (targetFingerPaintY - fingerPaintY) * easing;
  float weight = dist(fingerPaintX, fingerPaintY, fingerPaintPX, fingerPaintPY);

  float targetFingerPaintX2 = finger_position_2.x;
  fingerPaintX2 += (targetFingerPaintX2 - fingerPaintX2) * easing;
  float targetFingerPaintY2 = finger_position_2.y;
  fingerPaintY2 += (targetFingerPaintY2 - fingerPaintY2) * easing;
  float weight2 = dist(fingerPaintX2, fingerPaintY2, fingerPaintPX2, fingerPaintPY2);

  float targetFingerPaintX3 = finger_position_3.x;
  fingerPaintX3 += (targetFingerPaintX3 - fingerPaintX3) * easing;
  float targetFingerPaintY3 = finger_position_3.y;
  fingerPaintY3 += (targetFingerPaintY3 - fingerPaintY3) * easing;
  float weight3 = dist(fingerPaintX3, fingerPaintY3, fingerPaintPX3, fingerPaintPY3);

  float targetFingerPaintX4 = finger_position_4.x;
  fingerPaintX4 += (targetFingerPaintX4 - fingerPaintX4) * easing;
  float targetFingerPaintY4 = finger_position_4.y;
  fingerPaintY4 += (targetFingerPaintY4 - fingerPaintY4) * easing;
  float weight4 = dist(fingerPaintX4, fingerPaintY4, fingerPaintPX4, fingerPaintPY4);

  float targetFingerPaintX5 = finger_position_5.x;
  fingerPaintX5 += (targetFingerPaintX5 - fingerPaintX5) * easing;
  float targetFingerPaintY5 = finger_position_5.y;
  fingerPaintY5 += (targetFingerPaintY5 - fingerPaintY5) * easing;
  float weight5 = dist(fingerPaintX5, fingerPaintY5, fingerPaintPX5, fingerPaintPY5);


  for (Hand hand : leap.getHands ()) {
    for (Finger finger : hand.getFingers ()) {
      switch(finger.getType()) {
      case 0:
        finger_position_1 = finger.getPositionOfJointTip();
        strokeWeight(weight);
        stroke(redPixel*2, greenPixel*2, bluePixel*2, 100);       
        line(fingerPaintX, fingerPaintY, fingerPaintPX, fingerPaintPY);
        fingerPaintPY = fingerPaintY;
        fingerPaintPX = fingerPaintX;

        break;

      case 1:
        finger_position_2 = finger.getPositionOfJointTip();
        strokeWeight(weight2);
        //stroke(redPixel, greenPixel,bluePixel,100);       
        line(fingerPaintX2, fingerPaintY2, fingerPaintPX2, fingerPaintPY2);
        fingerPaintPY2 = fingerPaintY2;
        fingerPaintPX2 = fingerPaintX2;
        break;

      case 2:
        finger_position_3 = finger.getPositionOfJointTip();
        strokeWeight(weight3);
        // stroke(redPixel, greenPixel, bluePixel, 100);       
        line(fingerPaintX3, fingerPaintY3, fingerPaintPX3, fingerPaintPY3);
        fingerPaintPY3 = fingerPaintY3;
        fingerPaintPX3 = fingerPaintX3;
        break;

      case 3:
        finger_position_4 = finger.getPositionOfJointTip();
        strokeWeight(weight4);
        //stroke(redPixel, greenPixel,bluePixel, 100);       
        line(fingerPaintX4, fingerPaintY4, fingerPaintPX4, fingerPaintPY4);
        fingerPaintPY4 = fingerPaintY4;
        fingerPaintPX4 = fingerPaintX4;

        break;

      case 4:
        finger_position_5 = finger.getPositionOfJointTip();
        strokeWeight(weight5);
        // stroke(redPixel, greenPixel, bluePixel * 2, 100);       
        line(fingerPaintX5, fingerPaintY5, fingerPaintPX5, fingerPaintPY5);
        fingerPaintPY5 = fingerPaintY5;
        fingerPaintPX5 = fingerPaintX5;


        break;
      }
    }
  }
}

void LeapStage0() { //instructions and button for taking picture in stage 0
  if (cameraReady) {

    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0);

    //Visual of the button
    noStroke();
    fill(optionColor[index1]);
    rect(picbutton.x, picbutton.y, 250, 100);
    fill(0);
    text("take picture", picbutton.x + 30, picbutton.y + 50);

    //Leap pointer
    for (Hand hand : leap.getHands ()) {
      for (Finger finger : hand.getFingers ()) {
        if (finger.getType()==1) {
          println("index");
          PVector tempf = finger.getPosition();
          noStroke();
          if (onOption) {
            fill(rolloverColor);
          } else {
            fill(outsideColor);
          }
          ellipse(tempf.x, tempf.y, 30, 30);

          //use distance between the center of the option square and finger position to determine it is on the square
          // if (dist(picbutton.x+buttonSize/2, picbutton.y+buttonSize/2, tempf.x, tempf.y)<buttonSize/2) {
          if (dist(picbutton.x+250/2, picbutton.y+100/2 + 150/2, tempf.x, tempf.y) < 250/2 ) {

            //if the old number we remembered is not this number = a new option 
            if (oldNo != 1) {
              startTime = millis();
              oldNo = 1;
            } else {
              if (millis()-startTime>pauseTime) {
                //choices made switch to the next stage
                // optionColor = int(random(#E1F5C4, #FF4E50, #FF4E50, #FF4E50, #FF4E50)); //I know I need to turn this into an array but kept getting array index out of bounds
                index1 = int(random(optionColor.length));
                fill(optionColor[index1]);

                cam.stop();
                save("data/test1.jpg");
                lastTime = millis();
                stage=1;
                img = loadImage("test1.jpg");
                image(img, 0, 0);

                oldNo = 20;
              } else {
                stroke(255, 0, 0);
                noFill();
                ellipse(tempf.x, tempf.y, 200, 200);
                noStroke();
                fill(255, 0, 0, 100);
                float ratio = (millis()-startTime)*1.0/pauseTime;
                ellipse(tempf.x, tempf.y, ratio*200, ratio*200);
              }
            }
          }
        }
      }
    }
  }
}

void leapStage1to7() { //keypad and leap motion pointer for stages 1 - 7
  noStroke();
  for (int i=0; i<3; i++) {
    for (int j=0; j<3; j++) {
      fill(optionColor[index1]);
      rect(upperLeft_x+(buttonSize+spaceInBetween)*i, upperLeft_y+(buttonSize+spaceInBetween)*j, buttonSize, buttonSize);
      fill(255);
      noStroke();
      //adjust text position
      text(j*3+i, upperLeft_x+(buttonSize+spaceInBetween)*(i+0.5), upperLeft_y+(buttonSize+spaceInBetween)*(j+0.5));
    }
  }

  for (Hand hand : leap.getHands ()) {
    for (Finger finger : hand.getFingers ()) {
      if (finger.getType()==1) {
        println("index");
        PVector tempf = finger.getPosition();
        if (onOption) {
          fill(rolloverColor);
        } else {
          fill(outsideColor);
        }
        ellipse(tempf.x, tempf.y, 30, 30);

        //test if it is holding on 1 options;
        boolean onAnything = false;
        for (int i=0; i<3; i++) {
          for (int j=0; j<3; j++) {
            //use distance between the center of the option square and finger position to determine it is on the square
            if (dist(upperLeft_x+(buttonSize+spaceInBetween)*(i+0.5), upperLeft_y+(buttonSize+spaceInBetween)*(j+0.5), tempf.x, tempf.y)<buttonSize/2) {
              onAnything = true;
              //if the old number we remembered is not this number = a new option 
              if (oldNo != j*3+i) {
                startTime = millis();
                oldNo = j*3+i;
              } else {
                if (millis()-startTime>pauseTime) {
                  //choices made switch to the next stage
                  // optionColor = int(random(#E1F5C4, #FF4E50, #FF4E50, #FF4E50, #FF4E50)); //I know I need to turn this into an array but kept getting array index out of bounds
                  index1 = int(random(optionColor.length));
                  fill(optionColor[index1]);
                  updateData(j*3+i);
                  if (stage==7) {
                    background(255);
                  }
                  oldNo = 20;
                } else {
                  stroke(255, 0, 0);
                  noFill();
                  ellipse(tempf.x, tempf.y, 200, 200);
                  noStroke();
                  fill(255, 0, 0, 100);
                  float ratio = (millis()-startTime)*1.0/pauseTime;
                  ellipse(tempf.x, tempf.y, ratio*200, ratio*200);
                }
              }
            }
          }
        }

        if (onAnything) {
          onOption = true;
        } else {
          onOption = false;
          oldNo = 20;
        }
      }
    }
  }
}

void leapStage7() { //Go button and leap motion pointer 
  for (Hand hand : leap.getHands ()) {
    for (Finger finger : hand.getFingers ()) {
      if (finger.getType()==1) {
        println("index");
        PVector tempf = finger.getPosition();
        noStroke();
        if (onOption) {
          fill(rolloverColor);
        } else {
          fill(outsideColor);
        }
        ellipse(tempf.x, tempf.y, 30, 30);
        //use distance between the center of the option square and finger position to determine it is on the square
        if (dist(picbutton.x+250/2, picbutton.y+100/2 + 150/2, tempf.x, tempf.y) < 250/2 ) {
          //if the old number we remembered is not this number = a new option 
          if (oldNo != 1) {
            startTime = millis();
            oldNo = 1;
          } else {
            if (millis()-startTime>pauseTime) {
              //choices made switch to the next stage
              // optionColor = int(random(#E1F5C4, #FF4E50, #FF4E50, #FF4E50, #FF4E50)); //I know I need to turn this into an array but kept getting array index out of bounds
              index1 = int(random(optionColor.length));
              fill(optionColor[index1]);
              oldNo = 20;
              stage = 8;
              //before going to stage 8, whip the whole screen
              background(255);
            } else {
              stroke(255, 0, 0);
              noFill();
              ellipse(tempf.x, tempf.y, 200, 200);
              noStroke();
              fill(255, 0, 0, 100);
              float ratio = (millis()-startTime)*1.0/pauseTime;
              ellipse(tempf.x, tempf.y, ratio*200, ratio*200);
            }
          }
        }
      }
    }
  }
}

//leap motion 
//credit to https://github.com/voidplus/leap-motion-processing
// ========= CALLBACKS =========

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
  // println("Leap Motion Exit");
}

