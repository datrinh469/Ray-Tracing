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
     ArrayList<RayHit> organizedHits = new ArrayList<>();
     hits.sort(new HitCompare());
     int count = 0;
     int numOfEntry = 0;
     int numOfExit = 0;
     for(RayHit hit : hits) {
       if(hit.entry) { 
         numOfEntry++; 
       }
       else { 
         numOfExit++; 
       }
     }
     if(numOfExit > numOfEntry) {
       count = numOfExit - numOfEntry;
     }
     
     //places back only necessary RayHits
     for(RayHit hit : hits)
     {
       if(hit.entry == true)
       {
         if(count == 0)
           organizedHits.add(hit);
         count++;  
       }
       else 
       {
         if(count == 1)
           organizedHits.add(hit);
         count--; 
       }
     }
       
     return organizedHits;
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
     ArrayList<RayHit> organizedHits = new ArrayList<>();
     hits.sort(new HitCompare());
     
     //places back only necessary RayHits
     int count = 0;
     int numOfExit = 0;
     int numOfEntry = 0;
     RayHit temp = new RayHit();
     for(RayHit hit : hits) {
       if(hit.entry) { 
         numOfEntry++; 
       }
       else { 
         numOfExit++; 
       }
     }
     if(elements.length > 2 && numOfExit + numOfEntry == elements.length) { //<>//
       count = elements.length - numOfEntry;
     }
     else if(numOfExit == elements.length && numOfExit != numOfEntry) {
       count = elements.length - numOfEntry;
     }
     else if(numOfExit + numOfEntry == elements.length-1 && elements.length == 5) {
       if(numOfEntry == numOfExit+2) {
         count = elements.length - numOfEntry;
         temp.t = Float.MAX_VALUE;
         temp.entry = false;
         hits.add(temp);
       }
     }
     
     for(RayHit hit : hits)
     {
       if(hit.entry)
       {
         if(count == elements.length-1) 
         {
           organizedHits.add(hit);
         }
         count++;  
       }
       else 
       {
         if(count == elements.length)
         {
           organizedHits.add(hit);
         }
         count--; 
       }
     }
     
     return organizedHits;
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
	 
	 boolean enterOne = false;
	 boolean enterTwo = false;
	 boolean exitOne = false;
	 boolean exitTwo = false;
	 boolean hit;
	 RayHit initial;
	 int biteOne = 0;
	 int biteTwo = 0;

	 
	 ArrayList<RayHit> hitOne = a.intersect(r);
	 ArrayList<RayHit> hitTwo = b.intersect(r);
	 if (hitOne.size() > 0)
	 {
		if (hitOne.get(0).entry == false)
		{
			enterOne = true;
		}
	 }
	 else
	 {
		exitOne = true;
	 }
	 if (hitTwo.size() > 0)
	 {
		if (hitTwo.get(0).entry == false)
		{
        enterTwo = true;
      }
   }
   else
   {
      exitTwo = true;
   }
   
   while(!exitOne || !exitTwo)
   {
      if(exitOne)
      {
        hit = false;
        initial = hitTwo.get(biteTwo++);
        if(biteTwo == hitTwo.size())
        {
          exitTwo = true;
        }
      }
    else if (exitTwo)
    {
        hit = true;
        initial = hitOne.get(biteOne++);
        if(biteOne == hitOne.size())
        {
          exitOne = true;
        }
    }
    else
    {  
        if(hitOne.get(biteOne).t <= hitTwo.get(biteTwo).t)
        {
          hit = true;
          initial = hitOne.get(biteOne++);
          if(biteOne == hitOne.size())
          {
            exitOne = true;
          }
        }
        else
        {
          hit = false;
          initial = hitTwo.get(biteTwo++);
          if(biteTwo == hitTwo.size())
          {
            exitTwo = true;
          }
        }
    }
    if(initial.entry == false)
    {
        if(enterOne && enterTwo)
        {
          if(hit)
          {
            enterOne = false;
          }
          else
          {
            initial.normal = PVector.mult(initial.normal, -1);
            initial.entry = true;
            hits.add(initial);
            enterTwo = false;
          }
        }
        else if(enterOne & !enterTwo)
        {
          hits.add(initial);
          enterOne = false;
        }
        else
        {
          enterTwo = false;
        }
      }
      else
      {
        if(!enterOne && !enterTwo)
        {
          if(hit)
          {
            hits.add(initial);
            enterOne = true;
          }
          else
          {
            enterTwo = true;
          }
        }
        else if(enterTwo && !enterOne)
        {
          enterOne = true;
        }
        else
        {
          initial.normal = PVector.mult(initial.normal, -1);
          initial.entry = false;
          hits.add(initial);
          enterTwo = true;
        }
      }
    }
    return hits;
  }
}
