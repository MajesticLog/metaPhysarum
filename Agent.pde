// The agent, or the individual particle that will interact with others and form the physarum.

class Agent {


  //---------------------------------------------------- CLASS VARIABLES -----------------------------------------------------

  float turnAngle;           // Softology describes as "how quick the particles turn towards senses area"
  float heading, startH;     // Sage Jenson describes heading as the initial angle the agent is facing
  float senseAngle;          // Softology describes as "how wide the particle looks to the left and right"
  float senseDist;           // Softology describes as "how far in front the particle looks"
  float step, nStep, radius; // Take a small step after each loop; nStep updates the step, radius is the radius of the particles
  PVector pos, startPos, vel;// position of each agent, initial position (needed to keep bringing stray agents back in the window), velocity

  //------------------------------------------------------ CONSTRUCTOR -------------------------------------------------------

  Agent(PVector p) {            // Constructor for the class
    pos=p.copy();               // copy the original position vector to not affect anything
       vel=new PVector(0, 0);    // initial velocity
    heading=random(TWO_PI);     // agents facing around in a circle at random
    startH=heading;             // stores heading to return to the value when the agent leaves the window
    turnAngle=random(PI/6,PI/10);             // Softology describes as "how quick the particles turn towards senses area"
    step=random(10);          // Take a small step after each loop
    radius=1;                   // radius of the particle
    senseAngle=PI/4;            // arbitrary angle
    senseDist=10;               // will determine how close they stay so one another
    startPos=pos.copy();        // stores the starting position
  }

  //----------------------------------------------------------- UPDATE ---------------------------------------------------------

  void update() {
    headingSensors();            // calls the heading Sensors to check where to go and implement that
      heading+=setDir();          // add the calculated angle to the heading
    //vel=new PVector(cos(heading), sin(heading)).mult(nStep);      // velocity += acceleration, for accurate physarum
    vel.add(new PVector(cos(heading), sin(heading)));           // for funky shapes
    vel.setMag(nStep);                                          // arbitrary magnitude
    pos.add(vel);                                                 // movement = location += velocity

    checkEdge();                                                  // are we out of the window?
  }

  //------------------------------------------------------ CLASS METHODS -----------------------------------------------------

  int sense(float h, PVector p, float d, float a) {             // int as will return a value we can use to decide on which direction to take

    /* from Softology:  Turn the particle towards the highest pheromone intensity. 
     ie if the left spot is highest then subtract turn angle from the particle heading. 
     If the front is highest do not make any change to the particle heading. If the right 
     is highest add turn angle to the particle heading. You can also reverse this process 
     so the particles turn away from the highest pheromone levels.
     */

    // I wasn't sure how to sort between three without having to actually simulate a pheromone trail, but found this solution from https://www.raphaelperraud.com/

    float newAngle=a+h;                                                          // new angle from two angles passed to the function
    PVector desired = new PVector(cos(newAngle)*d, sin(newAngle)*d).add(p);      // trigonometry! y=radius*sin(angle), x=radius*cos(angle)  (polar coords to cartesian)
    color c=get(int(desired.x), int(desired.y));                                 // get color at agent location
    float colCheck = max(red(c), green(c), blue(c));                             // now we get the highest value of the three - the goal is to see if the area is dark, medium or bright


    // 1 for light, 2 for medium, 0 for dark! Checks the agent trail instead of checking a separate pheromone trail
    if ( colCheck > 255 / 3 ) return 1 ;
    else if ( colCheck > ( 255 * 2) / 3) return 2;
    else return 0 ;
  }


  boolean m_b (int i) {              // these two bools will help access the direction and add some randomness into the movement, as some hyphaes always stray and explore
    return (i == 1 || i == 2);
  }

  boolean d(int i) {
    return ( i == 0);
  }


  float setDir() {              // the color have determined the new direction

    int[] dir = new int[3];        // stores the 3 options 

    dir[0] = sense(heading, pos, senseDist, -senseAngle);        // left
    dir[1] = sense(heading, pos, senseDist, 0);                  // go forward
    dir[2] = sense(heading, pos, senseDist, senseAngle);         // right

    nStep=step;

    // turn randomly
    if ( m_b(dir[0]) && d(dir[1]) && m_b(dir[2]) ) {
      return random(1) > 0.5 ? turnAngle : -turnAngle;
    }

    // turn left
    else if ( m_b(dir[0]) && d(dir[2]) ) {
      return -turnAngle;
    }

    // turn right
    else if ( d(dir[0]) && m_b(dir[2]) ) {
      return turnAngle;
    } else {
      return 0.001; // .05
    }
  }

  void checkEdge() {                // if we're out of the window...
    if (pos.x<0||pos.x>width||pos.y<0||pos.y>height) {     
      pos.set(startPos);             // back to the beginning!
      heading=startH;
      step=random(10);
    }
  }
  void headingSensors() {            // updates heading, ie the general direction of the agent
    heading += setDir() ;
  }

  //----------------------------------------------------------- DISPLAY ---------------------------------------------------------

  void display() {
    noStroke();
    fill(255);
    ellipse(pos.x, pos.y, radius, radius);
  }
}
