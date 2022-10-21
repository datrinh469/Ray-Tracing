class MoveRotation implements SceneObject
{
  SceneObject child;
  PVector movement;
  PVector rotation;
  
  MoveRotation(SceneObject child, PVector movement, PVector rotation)
  {
    this.child = child;
    this.movement = movement;
    this.rotation = rotation;
    
  }
  
  void rotationZ(PVector r, PVector rotation)
  {
    float primeX = (cos(rotation.z) * r.x) - (sin(rotation.z) * r.y);
    float primeY = (sin(rotation.z) * r.x) + (cos(rotation.z) * r.y);
    r.x = primeX;
    r.y = primeY;
  }
  
  void rotationX(PVector r, PVector rotation)
  {
    float primeY = (cos(rotation.x) * r.y) - (sin(rotation.x) * r.z);
    float primeZ = (sin(rotation.x) * r.y) + (cos(rotation.x) * r.z);
    r.y = primeY;
    r.z = primeZ;
  }
  
  void rotationY(PVector r, PVector rotation)
  {
    float primeX = (cos(rotation.y) * r.x) + (sin(rotation.y) * r.z);
    float primeZ = (-sin(rotation.y) * r.x) + (cos(rotation.y) * r.z);
    r.x = primeX;
    r.z = primeZ;
  }
  
  void inverseRotationY(PVector r, PVector rotation)
  {
    float primeX = (cos(-rotation.y) * r.x) + (sin(-rotation.y) * r.z);
    float primeZ = (-sin(-rotation.y) * r.x) + (cos(-rotation.y) * r.z);
    r.x = primeX;
    r.z = primeZ;
  }
  
  void inverseRotationX(PVector r, PVector rotation)
  {
    float primeY = (cos(-rotation.x) * r.y) - (sin(-rotation.x) * r.z);
    float primeZ = (sin(-rotation.x) * r.y) + (cos(-rotation.x) * r.z);
    r.y = primeY;
    r.z = primeZ;
  }
  
  void inverseRotationZ(PVector r, PVector rotation)
  {
    float primeX = (cos(-rotation.z) * r.x) - (sin(-rotation.z) * r.y);
    float primeY = (sin(-rotation.z) * r.x) + (cos(-rotation.z) * r.y);
    r.x = primeX;
    r.y = primeY;
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
    //Step 1
    Ray currentRay = new Ray(r.origin, r.direction);
    currentRay.origin = PVector.sub(currentRay.origin, movement);
    inverseRotationY(currentRay.origin, rotation);
    inverseRotationX(currentRay.origin, rotation);
    inverseRotationZ(currentRay.origin, rotation);
    
    inverseRotationY(currentRay.direction, rotation);
    inverseRotationX(currentRay.direction, rotation);
    inverseRotationZ(currentRay.direction, rotation);
    
    //Step 2
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    hits.addAll(child.intersect(currentRay));
    
    //Step 3
    for(RayHit hit: hits)
    {
      rotationZ(hit.location, rotation);
      rotationX(hit.location, rotation);
      rotationY(hit.location, rotation);
      hit.location = PVector.add(hit.location, movement);
      
      rotationZ(hit.normal, rotation);
      rotationX(hit.normal, rotation);
      rotationY(hit.normal, rotation);
    }
    
    //Step 4
    return hits;
  }
}

class Scaling implements SceneObject
{
  SceneObject child;
  PVector scaling;
  
  Scaling(SceneObject child, PVector scaling)
  {
    this.child = child;
    this.scaling = scaling;
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
    //Step 1
    Ray currentRay = new Ray(r.origin, r.direction);
    currentRay.origin.x = currentRay.origin.x / scaling.x;
    currentRay.origin.y = currentRay.origin.y / scaling.y;
    currentRay.origin.z = currentRay.origin.z / scaling.z;
    
    currentRay.direction.x = currentRay.direction.x / scaling.x;
    currentRay.direction.y = currentRay.direction.y / scaling.y;
    currentRay.direction.z = currentRay.direction.z / scaling.z;
    currentRay.direction.normalize();
    
    //Step 2
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    hits.addAll(child.intersect(currentRay));
    
    //Step 3
    for(RayHit hit: hits)
    {
      hit.location.x = hit.location.x * scaling.x;
      hit.location.y = hit.location.y * scaling.y;
      hit.location.z = hit.location.z * scaling.z;
      
      hit.normal.x = hit.normal.x * scaling.x;
      hit.normal.y = hit.normal.y * scaling.y;
      hit.normal.z = hit.normal.z * scaling.z;
      hit.normal.normalize();
    }
    
    //Step 4
    return hits;
  }
}
