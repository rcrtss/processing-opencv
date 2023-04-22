// Particles, by Daniel Shiffman.

ParticleSystem ps1;
ParticleSystem ps2;
PImage sprite;  


import processing.net.*; 
Client myClient;

void setup() {
  size(1300, 720, P2D);
  orientation(LANDSCAPE);
  sprite = loadImage("sprite.png");
  ps1 = new ParticleSystem(300);
  ps2 = new ParticleSystem(300);

  // Writing to the depth buffer is disabled to avoid rendering
  // artifacts due to the fact that the particles are semi-transparent
  // but not z-sorted.
  hint(DISABLE_DEPTH_MASK);
  
  // Define Client IP  
  myClient = new Client(this, "127.0.0.1", 50007); 
} 

/*
String dataIn;
void draw () {
  background(0);
  int[] Data_array = new int[]{ 0,0,0,0,0,0,0,0 }; 
  if (myClient.available() > 0) { 
    dataIn = myClient.readString(); 
  }
  Data_array = ParseMessage(dataIn);
  
  ps1.update();
  ps1.display();
  
  ps1.setEmitter(Data_array[0],Data_array[1]);
  
  fill(255);
  textSize(16);
  text("Frame rate: " + Data_array[0], 10, 20);
  
}*/

String dataIn;
int counter = 0;
int[] Data_array = new int[]{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }; 
  

void draw() { 
  background(100);
  if (myClient.available() > 0 && counter == 0) { 
    myClient.write("Send me something");
    dataIn = myClient.readString();
    print("\n\n");
    println("Recieved:"); 
    println(dataIn);
    println("message sent");
    Data_array = ParseMessage(dataIn);
  } 
  
  ps1.update();
  ps1.display();
  ps2.update();
  ps2.display();
  
  println("Coordinates: ", Data_array[counter],Data_array[counter + 1]);
  ps1.setEmitter(Data_array[counter],Data_array[counter + 1]);
  ps2.setEmitter(Data_array[counter + 1] + 600,Data_array[counter]);
  
  if(counter < 20 - 2)
  {
    counter += 2;
  }
  else 
  {
    counter = 0;
  }
} 


/* x, y, RGB and RGB bckgnd 
 * returns array of ints with the data
 */
int[] ParseMessage(String dataIn)
{
  int[] results = new int[]{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }; 
  
  if(dataIn != null) 
  {
    int index_X = 0;
    int index_Y = 0;
    String s_X = "";
    String s_Y = "";
    
    for(int i = 0; i < 20; i = i + 2)
    {
      if(i == 0)
      {
        index_X = dataIn.indexOf(",");
        index_Y = dataIn.indexOf(",", index_X + 1);
        s_X = dataIn.substring(0, index_X);
        s_Y = dataIn.substring(index_X + 1, index_Y);
        results[0] = Integer.parseInt(s_X);
        results[1] = Integer.parseInt(s_Y);
      }
      else if(i == 20 - 2) // last
      {
        index_X = dataIn.indexOf(",", index_Y + 1);
        s_X = dataIn.substring(index_Y + 1, index_X);        
        index_Y = dataIn.length() - 1;
        s_Y = dataIn.substring(index_X + 1, index_Y);
        results[i] = Integer.parseInt(s_X);
        results[i+1] = Integer.parseInt(s_Y);
      }
      else
      {
        index_X = dataIn.indexOf(",", index_Y + 1);
        s_X = dataIn.substring(index_Y + 1, index_X); 
        index_Y = dataIn.indexOf(",", index_X + 1);
        s_Y = dataIn.substring(index_X + 1, index_Y);
        results[i] = Integer.parseInt(s_X);
        results[i+1] = Integer.parseInt(s_Y);
      }
    }
    
  } 
  
  println("Result:"); 
  
  for(int i = 0; i < 20; i ++)
  {
    print(results[i]);
    print(",");
  }
  print("\n");
  return results;
}
  
