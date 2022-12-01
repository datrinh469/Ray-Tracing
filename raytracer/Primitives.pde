class Sphere implements SceneObject
{
    PVector center;
    float radius;
    Material material;
    
    Sphere(PVector center, float radius, Material material)
    {
       this.center = center;
       this.radius = radius;
       this.material = material;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        float distanceRayToOrigin = PVector.dot(PVector.sub(center, r.origin), r.direction);
        PVector closestPointToRadius = PVector.add(r.origin, PVector.mult(r.direction, distanceRayToOrigin));
        float differenceOfClosestVectorPointToCenter = closestPointToRadius.dist(center);
        
        float deltaT = (float)Math.sqrt(sq(radius) - sq(differenceOfClosestVectorPointToCenter));
        float entrance = distanceRayToOrigin - deltaT;
          
        if(differenceOfClosestVectorPointToCenter < radius) {
          RayHit entry = new RayHit();
          entry.t = entrance;
          entry.location = PVector.add(r.origin, PVector.mult(r.direction, entry.t));
          entry.normal = PVector.sub(entry.location, center).normalize();
          entry.material = material;
          entry.entry = true;
          entry.u = 0.5 + (float)(Math.atan2(entry.normal.y, entry.normal.x)/(2*Math.PI));
          entry.v = 0.5 - (float)(Math.asin(entry.normal.z)/Math.PI);
          
          RayHit exit = new RayHit();
          exit.t = distanceRayToOrigin + deltaT;
          exit.location = PVector.add(r.origin, PVector.mult(r.direction, exit.t));
          exit.normal = PVector.sub(exit.location, center).normalize();
          exit.material = material;
          exit.entry = false;
          exit.u = 0.5 + (float)(Math.atan2(entry.normal.y, entry.normal.x)/(2*Math.PI));
          exit.v = 0.5 - (float)(Math.asin(entry.normal.z)/Math.PI);
          
          if(entry.t > 0)
          {
            result.add(entry);
          }
          if(exit.t > 0)
          {
            result.add(exit);
          }
        }
        return result;
    }
}

class Plane implements SceneObject
{
    PVector center;
    PVector normal;
    float scale;
    Material material;
    PVector right;
    PVector up;
    PVector d;
    float x;
    float y;
    
    Plane(PVector center, PVector normal, Material material, float scale)
    {
       this.center = center;
       this.normal = normal.normalize();
       this.material = material;
       this.scale = scale;
      
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        float tPlane = tHits(r.direction, center, r.origin, this.normal);
        PVector tPoint = PVector.add(PVector.mult(r.direction, tPlane), r.origin);
        RayHit pHit = new RayHit();
        
        if (tPlane > 0)
        {
          pHit.t  = tPlane;
          pHit.location = tPoint;
          pHit.normal = this.normal;
          if (PVector.dot(r.direction, this.normal) < 0)
          {
            pHit.entry = true;
          }
          else
          {
            pHit.entry = false;
          }
          pHit.material = this.material;
          if(!pHit.normal.equals(new PVector(0,0,1)))
          {
            right = PVector.cross(new PVector(0,0,1), pHit.normal, right);
          }
          else
          {
            right = PVector.cross(new PVector(0,1,0), pHit.normal, right);
          }
          right.normalize();
          up = PVector.cross(pHit.normal, right, up);
          up.normalize();
          d = PVector.sub(pHit.location, center);
          x = PVector.dot(d, right)/scale;
          y = PVector.dot(d, up)/scale;
          pHit.u = x - floor(x);
          pHit.v = -y - floor(-y);
          result.add(pHit);
        }
        return result;
    }
}

class Triangle implements SceneObject
{
    PVector v1;
    PVector v2;
    PVector v3;
    PVector normal;
    PVector tex1;
    PVector tex2;
    PVector tex3;
    Material material;
    
    ArrayList<Float> ComputeUV(PVector a, PVector b, PVector c, PVector p)
    {
      ArrayList<Float> result = new ArrayList<Float>();
      PVector e = PVector.sub(b, a);
      PVector g = PVector.sub(c, a);
      PVector d = PVector.sub(p, a);
      float denom = (PVector.dot(e, e) * PVector.dot(g, g)) - (PVector.dot(e, g) * PVector.dot(g, e));
      float u = ((PVector.dot(g, g) * PVector.dot(d, e)) - (PVector.dot(e, g) * PVector.dot(d, g)))/denom;
      float v = ((PVector.dot(e, e)*PVector.dot(d, g)) - (PVector.dot(e, g) * PVector.dot(d, e)))/denom;
      result.add(u);
      result.add(v);
      return result;
    }
    Boolean PointInTriangle(PVector a, PVector b, PVector c, PVector p)
    {
      ArrayList<Float> uv = ComputeUV(a, b, c, p);
      float u = uv.get(0);
      float v = uv.get(1);
      return (u >= 0) & (v >= 0) & (u + v) <= 1;
    }
     
    Triangle(PVector v1, PVector v2, PVector v3, PVector tex1, PVector tex2, PVector tex3, Material material)
    {
       this.v1 = v1;
       this.v2 = v2;
       this.v3 = v3;
       this.tex1 = tex1;
       this.tex2 = tex2;
       this.tex3 = tex3;
       this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
       this.material = material;
       
    }
    PVector triangleTextureCoord( float th, float ph)
    {
      PVector result;
      float psi = 1 - (th + ph);
      result = PVector.mult(tex2, th);
      result = PVector.add(result, PVector.mult(tex1, psi));
      result = PVector.add(result, PVector.mult(tex3, ph));
      return result;
    }
 
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        float tTriangle = tHits(r.direction, v1, r.origin, this.normal);
        PVector point = PVector.add(PVector.mult(r.direction, tTriangle), r.origin);
        ArrayList<Float> uv = ComputeUV(v1, v2, v3, point);
        if (PointInTriangle(v1, v2, v3, point) & tTriangle > 0)
        {

          RayHit TRI = new RayHit();
          TRI.t = tTriangle;
          TRI.location = point;          
          if (PVector.dot(r.direction, this.normal) <= 0)
          {
            TRI.normal = this.normal;
            TRI.entry = true;
          }
          else
          {
            TRI.normal = PVector.mult(this.normal, -1);
            
            TRI.entry = false;
          }
          TRI.u = uv.get(0);
          TRI.v = uv.get(1);
          TRI.material = this.material;
          if (TRI.u >= 0 && TRI.v >= 0 && (TRI.u + TRI.v)<= 1)
          {
            PVector img = triangleTextureCoord(TRI.u, TRI.v);
            TRI.u =  img.x;
            TRI.v = img.y;
            result.add(TRI);
          }
          
        }
          
        return result;
    }
}

class Cylinder implements SceneObject
{
    float radius;
    float height;
    Material material;
    float scale;
    
    Cylinder(float radius, Material mat, float scale)
    {
       this.radius = radius;
       this.height = -1;
       this.material = mat;
       this.scale = scale;
    }
    
    Cylinder(float radius, float height, Material mat, float scale)
    {
       this.radius = radius;
       this.height = height;
       this.material = mat;
       this.scale = scale;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        RayHit entryHit = new RayHit();
        RayHit exitHit = new RayHit();
        
        float a = sq(r.direction.x) + sq(r.direction.y);
        float b = (2*r.origin.x*r.direction.x) + (2*r.origin.y*r.direction.y);
        float c = sq(r.origin.x) + sq(r.origin.y) - sq(radius);
          
        float tEntry = (-b - sqrt(sq(b) - (4*a*c)))/(2*a);
        float tExit = (-b + sqrt(sq(b) - (4*a*c)))/(2*a);
        
        if(height == -1) {
          if(tEntry > 0 && tExit > 0) {
            
            entryHit.t = tEntry;
            entryHit.location = new PVector(r.origin.x + (tEntry*r.direction.x), 
              r.origin.y + (tEntry*r.direction.y), r.origin.z);
            entryHit.normal = new PVector(entryHit.location.x, entryHit.location.y, 0).normalize();
            entryHit.entry = true;
            entryHit.material = material;
            entryHit.u = 0;
            entryHit.v = 0;
            
            exitHit.t = tExit;
            exitHit.location = new PVector(r.origin.x + (tExit*r.direction.x),
              r.origin.y + (tExit*r.direction.y), r.origin.z);
            exitHit.normal = new PVector(exitHit.location.x, exitHit.location.y, 0).normalize();
            exitHit.entry = false;
            exitHit.material = material;
            exitHit.u = 0;
            exitHit.v = 0;
            
            result.add(entryHit);
            result.add(exitHit);
          }
        }
        
        else {
          
          PVector normTop = new PVector(0,0,1);
          PVector normBottom = new PVector(0,0,-1);
          PVector centerPlaneTop = new PVector(0,0,height);
          PVector centerPlaneBot = new PVector(0,0,0);
          
          float tPlaneTop = tHits(r.direction, centerPlaneTop, r.origin, normTop);
          PVector tPointTop = PVector.add(PVector.mult(r.direction, tPlaneTop), r.origin);
          
          float tPlaneBot = tHits(r.direction, centerPlaneBot, r.origin, normBottom);
          PVector tPointBot = PVector.add(PVector.mult(r.direction, tPlaneBot), r.origin);
          
          if(tEntry > 0 && tExit > 0) {
            entryHit.t = tEntry;
            entryHit.location = new PVector(r.origin.x + (tEntry*r.direction.x), 
              r.origin.y + (tEntry*r.direction.y), r.origin.z);
            entryHit.normal = new PVector(entryHit.location.x, entryHit.location.y, 0).normalize();
            entryHit.entry = true;
            entryHit.material = material;
            entryHit.u = 0;
            entryHit.v = 0;
            
            exitHit.t = tExit;
            exitHit.location = new PVector(r.origin.x + (tExit*r.direction.x),
              r.origin.y + (tExit*r.direction.y), r.origin.z);
            exitHit.normal = new PVector(exitHit.location.x, exitHit.location.y, 0).normalize();
            exitHit.entry = false;
            exitHit.material = material;
            exitHit.u = 0;
            exitHit.v = 0;
             
            if(entryHit.location.z < 0 || entryHit.location.z > height) {
              if (tPlaneBot > 0) {
              entryHit.t  = tPlaneBot;
              entryHit.location = tPointBot;
              entryHit.normal = normBottom;
              }
            }
            if(exitHit.location.z < 0 || exitHit.location.z > height) {
              if (tPlaneBot > 0) {
              exitHit.t  = tPlaneBot;
              exitHit.location = tPointBot;
              exitHit.normal = normBottom;
              }
            }
          }
        }
        
        return result;
    }
}

class Cone implements SceneObject
{
    Material material;
    float scale;
    
    Cone(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement cones
       throw new NotImplementedException("Cones not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class Paraboloid implements SceneObject
{
    Material material;
    float scale;
    
    Paraboloid(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement paraboloids
       throw new NotImplementedException("Paraboloid not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class HyperboloidOneSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidOneSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement one-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of one sheet not implemented yet");
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class HyperboloidTwoSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidTwoSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement two-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of two sheets not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}