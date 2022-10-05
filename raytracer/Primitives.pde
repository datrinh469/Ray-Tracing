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
          
        if(differenceOfClosestVectorPointToCenter < radius && entrance >= 0) {
          RayHit entry = new RayHit();
          entry.t = entrance;
          entry.location = PVector.add(r.origin, PVector.mult(r.direction, entry.t));
          entry.normal = PVector.sub(entry.location, center).normalize();
          entry.material = material;
          entry.entry = true;
          entry.u = 0;
          entry.v = 0;
          
          RayHit exit = new RayHit();
          exit.t = distanceRayToOrigin + deltaT;
          exit.location = PVector.add(r.origin, PVector.mult(r.direction, exit.t));
          exit.normal = PVector.sub(exit.location, center).normalize();
          exit.material = material;
          exit.entry = false;
          exit.u = 0;
          exit.v = 0;
          
          result.add(entry);
          result.add(exit);
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
    PVector left;
    PVector up;
    
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
          TRI.normal = this.normal;
          if (PVector.dot(r.direction, this.normal) < 0)
          {
            TRI.entry = true;
          }
          else
          {
            TRI.entry = false;
          }
          TRI.u = uv.get(0);
          TRI.v = uv.get(1);
          TRI.material = this.material;
          result.add(TRI);
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
       
       // remove this line when you implement cylinders
       throw new NotImplementedException("Cylinders not implemented yet");
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
