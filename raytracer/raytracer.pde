String input =  "data/tests/milestone3/test10.json";
String output = "data/tests/milestone1/test1.png";
int repeat = 0;

int iteration = 0;

// If there is a procedural material in the scene,
// loop will automatically be turned on if this variable is set
boolean doAutoloop = true;

/*// Animation demo:
String input = "data/tests/milestone3/animation1/scene%03d.json";
String output = "data/tests/milestone3/animation1/frame%03d.png";
int repeat = 100;
*/


RayTracer rt;

void setup() {
  size(640, 640);
  noLoop();
  if (repeat == 0)
      rt = new RayTracer(loadScene(input));  
  
}

void draw () {
  background(255);
  if (repeat == 0)
  {
    PImage out = null;
    if (!output.equals(""))
    {
       out = createImage(width, height, RGB);
       out.loadPixels();
    }
    for (int i=0; i < width; i++)
    {
      for(int j=0; j< height; ++j)
      {
        color c = rt.getColor(i,j);
        set(i,j,c);
        if (out != null)
           out.pixels[j*width + i] = c;
      }
    }
    
    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
    /*for (int i = 0; i< 3; ++i)
    {
      for (int j = 0; j< 3; ++j)
         set(315+i,315+j, rt.getColor(315+i,315+j));
    }*/
    
    if (out != null)
    {
       out.updatePixels();
       out.save(output);
    }
    
  }
  else
  {
     // With this you can create an animation!
     // For a demo, try:
     //    input = "data/tests/milestone3/animation1/scene%03d.json"
     //    output = "data/tests/milestone3/animation1/frame%03d.png"
     //    repeat = 100
     // This will insert 0, 1, 2, ... into the input and output file names
     // You can then turn the frames into an actual video file with e.g. ffmpeg:
     //    ffmpeg -i frame%03d.png -vcodec libx264 -pix_fmt yuv420p animation.mp4
     String inputi;
     String outputi;
     for (; iteration < repeat; ++iteration)
     {
        inputi = String.format(input, iteration);
        outputi = String.format(output, iteration);
        if (rt == null)
        {
            rt = new RayTracer(loadScene(inputi));
        }
        else
        {
            rt.setScene(loadScene(inputi));
        }
        PImage out = createImage(width, height, RGB);
        out.loadPixels();
        for (int i=0; i < width; i++)
        {
          for(int j=0; j< height; ++j)
          {
            color c = rt.getColor(i,j);
            out.pixels[j*width + i] = c;
            if (iteration == repeat - 1)
               set(i,j,c);
          }
        }
        out.updatePixels();
        out.save(outputi);
     }
  }
  updatePixels();


}

class Ray
{
     Ray(PVector origin, PVector direction)
     {
        this.origin = origin;
        this.direction = direction;
     }
     PVector origin;
     PVector direction;
     
}

// TODO: Start in this class!
class RayTracer
{
    Scene scene;  
    
    RayTracer(Scene scene)
    {
      setScene(scene);
    }
    
    void setScene(Scene scene)
    {
       this.scene = scene;
    }
    
    color getColor(int x, int y)
    {
      PVector origin = scene.camera;
      
      float w = width;
      float h = height;
      
      float u = x*1.0/w - 0.5;
      float v = - (y*1.0/h - 0.5);
      
      PVector direction = new PVector(u*w, w/2, v*h).normalize();
      
      Ray ray = new Ray(origin, direction);
      
      ArrayList<RayHit> hits = scene.root.intersect(ray);
      if (hits.size() > 0) {
        if (scene.reflections > 0 && hits.get(0).material.properties.reflectiveness > 0)
        {
          //initializes variables
          color reflection = scene.lighting.getColor(hits.get(0), scene, ray.origin);
          PVector R, TwoN;
          PVector N = hits.get(0).normal; 
          PVector V = PVector.sub(ray.origin, hits.get(0).location).normalize(); 
          float NV;
          Ray reflectRay = ray;
          int reflectCount = 0;
          
          //repeat process until done
          while(reflectCount <= scene.reflections && hits.size() > 0)
          {
            V = PVector.sub(reflectRay.origin, hits.get(0).location).normalize();
            N = hits.get(0).normal;
            
            TwoN = PVector.mult(N, 2);  //2N
            NV = PVector.dot(N, V);    //N*V
            
            //R = 2N(N*V) - V
            R = PVector.sub(PVector.mult(TwoN, NV), V);
            
            //creates the new ray with origin at intersection and shoot it into scene
            float previousReflectiveness = hits.get(0).material.properties.reflectiveness;    //grabs current object reflectiveness
            reflectRay = new Ray(PVector.add(hits.get(0).location, PVector.mult(R, EPS)), R);
            hits = scene.root.intersect(reflectRay);
            
            if(hits.size() > 0 && previousReflectiveness > 0)
            {
              reflection = lerpColor(reflection, scene.lighting.getColor(hits.get(0), scene, reflectRay.origin), previousReflectiveness);
            }
            else
            {
              break;
            }
            reflectCount++;
          }
          
          return reflection;
          
        }
        //return multColor(color(255,0,0), -hits.get(0).normal.x);
        return scene.lighting.getColor(hits.get(0), scene, ray.origin);
      }
      
      
      
      return this.scene.background;
    }
}
