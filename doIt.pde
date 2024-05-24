/*
Zoé Caudron
 
 METAPHYS(ARUMS)
 
 This sketch is about understanding and reproducing a Physarum(slime mould) simulation with metaballs, just for the aesthetics (I like shiny things).
 
 I also started working on a version that takes in values from an Arduino sensor, to make it more interactive.
 
 I ended up struggling through way too many iterations, until I found some more resources from https://www.raphaelperraud.com/ - the 
 interesting tricky bits are from him! My intial approach was to simulate a grid on which I could add pheromone trails, as per 
 Sage J and Softology's explanations, but completely ran out of time. Raphael's way of assessing where to go next 
 is less accurate but also easier to implement and understand.
 
 All code decyphered, inspired, understood via Daniel Shiffman (steering behaviours, flocking etc), Softology (https://softologyblog.wordpress.com/2019/04/11/physarum-simulations/), Sage Jenson (https://cargocollective.com/sagejenson/physarum),
 Seb Lague (https://github.com/SebLague/Slime-Simulation) and this paper https://uwe-repository.worktribe.com/preview/980585/artl.2010.16.2.pdf
 
 Any bugs? No! But the performance is terrible. The way I implemented the metaball is very heavy, so unless you render
 frame by frame it won't look like much.
 You can however comment out the metaball bit and uncomment the b.display to see the simulation with particles - make sure to 
 put numOfPart to something like 15000! And to uncomment the trail effect.
 
 Next steps: reworking the Arduino sensor connection to optimise it, and reworking the code to add the pheromone trails and elaborate my own, fully functional version of this fascinating algorithm. Exploring other cellular automata.
 Learning more about shaders to implement a slime mould in this way?
 
 */

//---------------------------------------------------- GLOBAL VARIABLES -----------------------------------------------------
//Trail t;
ArrayList<Agent> blob=new ArrayList<Agent>();      // new Array of agents
int numOfPart=15000;        // desired number of agents/particles (arbitrary)

//--------------------------------------------------------- SETUP -----------------------------------------------------------

void setup() {
  size(1000, 1000);                                    // P2D renders with openGL, which is a little faster but with a lesser quality
  background(0);
  //  smooth(8);                                                // anti aliasing to keep good visuals

  for ( float i = 0; i <= numOfPart; ++i ) {      
    blob.add(new Agent(new PVector(width/2, height/2)));    // fill the ArrayList
  }
}


//---------------------------------------------------------- DRAW -----------------------------------------------------------

void draw() {

  //------ TRAIL ------
  noStroke();
  fill(0, 35);
  rect(0, 0, width, height);  // transparent black rect to create a trail effect

  //-------- METABALLS --------
  loadPixels();                                   //using pixels
  for (int x=0; x<width; x++) {                   // nested for loop to cover all the sketch window as a grid
    for (int y=0; y<height; y++) {
      int index=x+y*width;
      float sum=0;
      for (Agent b : blob) {
        float d=dist(x, y, b.pos.x, b.pos.y);  // distance from x,y to position of blob
        sum+=2*b.radius/d;
      }
      pixels[index]=color(sum/2, sum/4, sum);
    }
  }

  updatePixels();
  for (Agent b : blob) {      // Shiffman's favourite magic for loop! For every object b in the array blob...
    b.update();
    //   b.display();
  }
  if (frameCount<1500) {
    saveFrame("two-####.png");
  }
}
