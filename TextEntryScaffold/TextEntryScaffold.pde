import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final float DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*3; //aka, 1.0 inches square!
PImage watch;
PImage finger;
PFont fontSmall;
PFont fontLarge;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  fontSmall = createFont("Arial", 9);
  fontLarge = createFont("Arial", 16);
  //noCursor();
  watch = loadImage("watchhand3smaller.png");
  //finger = loadImage("pngeggSmaller.png"); //not using this
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(600, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 20)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background

  //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!", width/2, 200); //output
    text("Total time taken: " + (finishTime - startTime), width/2, 220); //output
    text("Total letters entered: " + lettersEnteredTotal, width/2, 240); //output
    text("Total letters expected: " + lettersExpectedTotal, width/2, 260); //output
    text("Total errors entered: " + errorsTotal, width/2, 280); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm, width/2, 300); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors, 1, 3), width/2, 320); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty, width/2, 340);
    text("WPM w/ penalty: " + (wpm-penalty), width/2, 360); //yes, minus, because higher WPM is better
    return;
  }

  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  drawKeyboard();
  textFont(fontLarge);
  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far

    //draw very basic next button
    fill(255, 0, 0);
    rect(400, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 450, 650); //draw next label
  }
  fill(255, 40);
  ellipse(mouseX, mouseY, 20, 20);
  textAlign(CENTER);
  fill(200);
  text("" + currentTyped, width/2, height/2-sizeOfInputArea/3); //draw current letter
  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device

  if (isBackspacePressed && millis() - backspacePressedTime > longPressThreshold) {
    int lastSpaceIndex = currentTyped.lastIndexOf(' ');
    if (lastSpaceIndex != -1) {
      currentTyped = currentTyped.substring(0, lastSpaceIndex + 1);
    } else {
      currentTyped = "";
    }
    isBackspacePressed = false;
  }
}


// Varaibles for keyboard drawing
float keyboardWidth = sizeOfInputArea;
float keyboardHeight = 3*sizeOfInputArea/4;
float keyWidth = keyboardWidth / 10 -4;
float keyHeight = keyboardHeight / 4 -4;
char selectedKey = ' ';
boolean isUpperCase = false;
String[] keys = {"QWERASD", "TYFGH", "UIOPJKL", "ZXC", "VBNM", "^     <"};
float keyMargin =sizeOfInputArea/30;
float cornerRadius = 5;
boolean isBackspacePressed = false;
float backspacePressedTime = 0;
float longPressThreshold = 600;

// variable for floating rect
char lastPressedKey = ' ';
float lastPressedKeyX = 0;
float lastPressedKeyY = 0;
boolean isKeyPressed = false;
int keySelected=0;
void drawKeyboard() {
  textFont(fontSmall);
  float startX =width/2;
  float startY =height/2-sizeOfInputArea/2+ sizeOfInputArea/4 ;
  if (!isKeyPressed) {
    fill(200);
    // try to draw the first button
    // first button xy
    float buttonX = startX-keyboardWidth/2+keyMargin;
    float buttonY = startY+keyMargin;
    float buttonWidth = keyboardWidth/3;
    float buttonHeight = keyboardHeight/3;
    quad(buttonX, buttonY,
      buttonX+buttonWidth, buttonY,
      buttonX+buttonWidth-6, buttonY+buttonHeight,
      buttonX+buttonWidth/4, buttonY+buttonHeight);
    fill(0);
    text(keys[0].substring(0, 4), buttonX+buttonWidth/2, buttonY+buttonHeight/2);
    text(keys[0].substring(4, 7), buttonX+buttonWidth/2, buttonY+buttonHeight/2+10);

    // second button
    fill(200);
    buttonX = startX-keyboardWidth/10;
    buttonY = startY+keyMargin;
    buttonWidth = keyboardWidth/3;
    buttonHeight =  keyboardHeight/3;
    quad(buttonX, buttonY,
      buttonX+keyboardWidth/5, buttonY,
      buttonX+keyboardWidth/5+10, buttonY+keyboardHeight/3,
      buttonX-6, buttonY+keyboardHeight/3);
    fill(0);
    text(keys[1].substring(0, 2), startX, buttonY+buttonHeight/2);
    text(keys[1].substring(2, 5), startX, buttonY+buttonHeight/2+10);

    // third button
    fill(200);
    // try to draw the first button
    // first button xy
    buttonX = startX+keyboardWidth/2-keyMargin;
    buttonY = startY+keyMargin;
    buttonWidth = keyboardWidth/3;
    buttonHeight = keyboardHeight/3;
    quad(buttonX, buttonY,
      buttonX-buttonWidth, buttonY,
      buttonX-buttonWidth+10, buttonY+buttonHeight,
      buttonX-buttonWidth/4, buttonY+buttonHeight);
    fill(0);
    text(keys[2].substring(0, 4), buttonX-buttonWidth/2, buttonY+buttonHeight/2);
    text(keys[2].substring(4, 7), buttonX-buttonWidth/2, buttonY+buttonHeight/2+10);


    // fourth button
    fill(200);
    buttonWidth = keyboardWidth/2;
    buttonHeight = keyboardHeight/4;
    buttonX = startX-buttonWidth+keyMargin;
    buttonY = startY+keyboardHeight/3+2*keyMargin;
    rect(buttonX, buttonY, buttonWidth-2*keyMargin, buttonHeight, cornerRadius);
    fill(0);
    text(keys[3], buttonX+buttonWidth/2, buttonY+buttonHeight/2);

    // fifth button
    fill(200);
    buttonWidth = keyboardWidth/2;
    buttonHeight = keyboardHeight/4;
    buttonX = startX+keyMargin;
    buttonY = startY+keyboardHeight/3+2*keyMargin;
    rect(buttonX, buttonY, buttonWidth-2*keyMargin, buttonHeight, cornerRadius);
    fill(0);
    text(keys[4], buttonX+buttonWidth/2-keyMargin, buttonY+buttonHeight/2);
    
    //blankspace
    fill(200);
    rect(width/2-keyboardWidth/2+2*keyMargin+keyboardWidth/5,buttonY+2*keyboardHeight/5-2*keyMargin,60,buttonHeight,cornerRadius);
    
    //delete
    rect(width/2+keyboardWidth/4+keyMargin,buttonY+2*keyboardHeight/5-2*keyMargin,20,buttonHeight,cornerRadius);
    fill(0);
    text("<",width/2+keyboardWidth/4+keyMargin+10,buttonY+6*keyboardHeight/10-3*keyMargin);
  } else if (isKeyPressed && keySelected == 0) {
    float keyWidth = keyboardWidth/5;
    float keyHeight = keyboardWidth/5;
    for (int i = 0; i<4; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+i*(keyWidth+keyMargin)+2*keyMargin, height/2-keyHeight, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[0].charAt(i), startX-keyboardWidth/2+i*(keyWidth+keyMargin)+keyMargin+keyWidth/2, height/2-keyHeight/2+keyMargin);
    }
    for (int i = 4; i<7; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+keyWidth/2+(i-4)*(keyWidth+keyMargin)+2*keyMargin, height/2+keyHeight/2, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[0].charAt(i), startX-keyboardWidth/2+(i-4)*(keyWidth+keyMargin)+keyMargin+keyWidth, height/2+keyHeight+keyMargin);
    }
  } else if (isKeyPressed && keySelected == 1) {
    float keyWidth = keyboardWidth/5;
    float keyHeight = keyboardWidth/5;
    for (int i = 0; i<2; i++) {
      fill(200);
      rect(startX+i*(keyWidth+keyMargin)-keyWidth, height/2-keyHeight, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[1].charAt(i), startX+i*(keyWidth+keyMargin)-keyWidth/2, height/2-keyHeight/2+keyMargin);
    }
    for (int i = 2; i<5; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+keyWidth/2+(i-2)*(keyWidth+keyMargin)+2*keyMargin, height/2+keyHeight/2, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[1].charAt(i), startX-keyboardWidth/2+(i-2)*(keyWidth+keyMargin)+keyMargin+keyWidth, height/2+keyHeight+keyMargin);
    }
  } else if (isKeyPressed && keySelected == 2) {
    float keyWidth = keyboardWidth/5;
    float keyHeight = keyboardWidth/5;
    for (int i = 0; i<4; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+i*(keyWidth+keyMargin)+2*keyMargin, height/2-keyHeight, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[2].charAt(i), startX-keyboardWidth/2+i*(keyWidth+keyMargin)+keyMargin+keyWidth/2, height/2-keyHeight/2+keyMargin);
    }
    for (int i = 4; i<7; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+keyWidth/2+(i-4)*(keyWidth+keyMargin)+2*keyMargin, height/2+keyHeight/2, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[2].charAt(i), startX-keyboardWidth/2+(i-4)*(keyWidth+keyMargin)+keyMargin+keyWidth, height/2+keyHeight+keyMargin);
    }
  } else if (isKeyPressed && keySelected == 3) {
    float keyWidth = keyboardWidth/5;
    float keyHeight = keyboardWidth/5;
    for (int i = 0; i<3; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+i*(keyWidth+keyMargin)+2*keyMargin, height/2+keyHeight/2, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[3].charAt(i), startX-keyboardWidth/2+i*(keyWidth+keyMargin)+keyMargin+keyWidth/2, height/2+keyHeight+keyMargin);
    }
  } else if (isKeyPressed && keySelected == 4) {
    float keyWidth = keyboardWidth/5;
    float keyHeight = keyboardWidth/5;
    for (int i = 0; i<4; i++) {
      fill(200);
      rect(startX-keyboardWidth/2+i*(keyWidth+keyMargin)+2*keyMargin, height/2+keyHeight/2, keyWidth-keyMargin, keyHeight, cornerRadius);
      fill(0);
      text(keys[4].charAt(i), startX-keyboardWidth/2+i*(keyWidth+keyMargin)+keyMargin+keyWidth/2, height/2+keyHeight+keyMargin);
    }
  }
}
//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

//my terrible implementation you can entirely replace
void mousePressed()
{
  // keyboard
  float startX = width / 2;
  float startY = height / 2 - sizeOfInputArea / 2 + sizeOfInputArea / 4;
  float keyWidth = keyboardWidth / 5;
  float keyHeight = keyboardWidth / 5;
  if (!isKeyPressed) {
    // 检测五个大区域中的哪一个被点击
    if (mouseY > startY && mouseY < startY +40) {
      if (mouseX > startX - keyboardWidth / 2 && mouseX < startX - keyboardWidth / 2+48) {
        keySelected = 0;
      } else if (mouseX > startX - keyboardWidth/2+48 && mouseX < startX - keyboardWidth /2 + 72) {
        keySelected = 1;
      } else if (mouseX > startX - keyboardWidth/2+72 && mouseX < startX - keyboardWidth /2 + 120) {
        keySelected = 2;
      }
      isKeyPressed = true;
    }
    if (mouseY > startY+40 && mouseY < startY + 60) {
      if (mouseX > startX - keyboardWidth / 2 && mouseX < startX - keyboardWidth / 2+60) {
        keySelected = 3;
      } else if (mouseX > startX - keyboardWidth/2+60 && mouseX < startX + keyboardWidth /2 + 120) {
        keySelected = 4;
      }
      isKeyPressed = true;
    }
    if (mouseY > startY+60&& mouseY < startY + 90) {
      if (mouseX > startX - keyboardWidth / 2 +30 && mouseX < startX - keyboardWidth / 2+90) {
        currentTyped += " ";
      }
      if (mouseX > startX - keyboardWidth / 2 +90 && mouseX < startX - keyboardWidth / 2+120) {
         if (currentTyped.length() > 0) {
          currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
          }
      }
    }
  }
  if (isKeyPressed) {
    if (mouseX >= startX-keyboardWidth/2 && mouseX <= startX+keyboardWidth/2 && mouseY >= startY +sizeOfInputArea/2+10 && mouseY <= startY +3*sizeOfInputArea/4) {
      isKeyPressed = false;
    }
    if (keySelected == 0) {
      for (int i = 0; i < 4; i++) {
        float keyX = startX - keyboardWidth / 2 + i * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 - keyHeight;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          // 处理第一行按钮的点击
          char selectedChar = keys[0].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
      for (int i = 4; i < 7; i++) {
        float keyX = startX - keyboardWidth / 2 + keyWidth / 2 + (i - 4) * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 + keyHeight / 2;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[0].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
    }
    if ( keySelected == 1) {
      for (int i = 0; i < 2; i++) {
        float keyX = startX + i * (keyWidth + keyMargin) - keyWidth;
        float keyY = height / 2 - keyHeight;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[1].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
      for (int i = 2; i < 5; i++) {
        float keyX = startX - keyboardWidth / 2 + keyWidth / 2 + (i - 2) * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 + keyHeight / 2;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[1].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
    }
    if (keySelected == 2) {
      for (int i = 0; i < 4; i++) {
        float keyX = startX - keyboardWidth / 2 + i * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 - keyHeight;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[2].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
      for (int i = 4; i < 7; i++) {
        float keyX = startX - keyboardWidth / 2 + keyWidth / 2 + (i - 4) * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 + keyHeight / 2;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[2].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
    }
    if ( keySelected == 3) {
      for (int i = 0; i < keys[3].length(); i++) {
        float keyX = startX - keyboardWidth / 2 + i * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 + keyHeight / 2;
        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin  && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[3].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
    }
    if ( keySelected == 4) {
      for (int i = 0; i < keys[4].length(); i++) {
        float keyX = startX - keyboardWidth / 2 + i * (keyWidth + keyMargin) + 2 * keyMargin;
        float keyY = height / 2 + keyHeight / 2;

        if (mouseX >= keyX && mouseX <= keyX + keyWidth - keyMargin && mouseY >= keyY && mouseY <= keyY + keyHeight) {
          char selectedChar = keys[4].charAt(i);
          selectedChar = isUpperCase ? Character.toUpperCase(selectedChar) : Character.toLowerCase(selectedChar);
          currentTyped += selectedChar;
          
        }
      }
    }
 }
 



  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(400, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}
void mouseReleased() {
  isBackspacePressed = false;
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  //image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger, 52, 341);
  if (mousePressed)
    fill(0);
  else
    fill(255);
  ellipse(0, 0, 5, 5);

  popMatrix();
}


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
