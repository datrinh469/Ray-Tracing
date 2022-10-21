import java.util.Comparator;

class HitCompare implements Comparator<RayHit>
{
  int compare(RayHit a, RayHit b)
  {
     if (a.t < b.t) return -1;
     if (a.t > b.t) return 1;
     if (a.entry) return -1;
     if (b.entry) return 1;
     return 0;
  }
}

class Union implements SceneObject
{
  SceneObject[] children;
  Union(SceneObject[] children)
  {
    this.children = children;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
     
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     for (SceneObject sc : children)
     {
       hits.addAll(sc.intersect(r));
     }
     
     //removes hits from disorganized list and places them into array to reorganize them
     RayHit[] organizedHits = new RayHit[hits.size()];
     for (int i = 0; i < organizedHits.length; i++)
     {
       organizedHits[i] = hits.remove(0);
     }
     
     //sorting algorithm incase num of RayHits is larger than 1
     if(organizedHits.length > 1) {
       for(int i = 1; i < organizedHits.length; i++)
       {
         RayHit key = organizedHits[i];
         int j = i - 1;
         
         while(j >= 0 && organizedHits[j].location.mag() > key.location.mag())
         {
           organizedHits[j+1] = organizedHits[j];
           j -= 1;
         }
         organizedHits[j+1] = key;
       }
     }
     
     //places back only necessary RayHits
     int count = 0;
     for(RayHit hit : organizedHits)
     {
       if(hit.entry == true)
       {
         if(count == 0)
           hits.add(hit);
         count++;  
       }
       else 
       {
         if(count == 1)
           hits.add(hit);
         count--; 
       }
     }
       
     return hits;
  }
  
}

class Intersection implements SceneObject
{
  SceneObject[] elements;
  Intersection(SceneObject[] elements)
  {
    this.elements = elements;
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     for (SceneObject sc : elements)
     {
       hits.addAll(sc.intersect(r));
     }
     
     //removes hits from disorganized list and places them into array to reorganize them
     RayHit[] organizedHits = new RayHit[hits.size()];
     for (int i = 0; i < organizedHits.length; i++)
     {
       organizedHits[i] = hits.remove(0);
     }
     
     //sorting algorithm incase num of RayHits is larger than 1
     if(organizedHits.length > 1) {
       for(int i = 1; i < organizedHits.length; i++)
       {
         RayHit key = organizedHits[i];
         int j = i - 1;
         
         while(j >= 0 && organizedHits[j].location.mag() > key.location.mag())
         {
           organizedHits[j+1] = organizedHits[j];
           j -= 1;
         }
         organizedHits[j+1] = key;
       }
     }
     
     //places back only necessary RayHits
     int count = 0;
     for(RayHit hit : organizedHits)
     {
       if(hit.entry == true)
       {
         if(count == elements.length-1)
           hits.add(hit);
         count++;  
       }
       else 
       {
         if(count == elements.length)
           hits.add(hit);
         count--; 
       }
     }
       
     return hits;
  }
  
}

class Difference implements SceneObject
{
  SceneObject a;
  SceneObject b;
  Difference(SceneObject a, SceneObject b)
  {
    this.a = a;
    this.b = b;
    
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
	 boolean bite1;
	 boolean bite2;
	 ArrayList<RayHit> hitOne = a.intersect(r);
	 ArrayList<RayHit> hitTwo = b.intersect(r);
	 if (hitOne.size() > 0)
	 {
		if (hitOne.get(0).entry == false)
		{
			bite1 = true;
		}
	 }
	 if (hitTwo.size() > 0)
	 {
		if (hitTwo.get(0).entry == false)
		{
			bite2 = true;
		}
	 }
	 hits.addAll(a.intersect(r));
	 hits.addAll(b.intersect(r));
	 hits.sort(new HitCompare());


     return hits;
  }
  
}
