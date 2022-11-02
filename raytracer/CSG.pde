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
     
     //places back only necessary RayHits
     int count = 0;
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
     for(RayHit hit : hits)
     {
       if(hit.entry == true)
       {
         if(count == elements.length-1)
         {
           organizedHits.add(hit);
           System.out.println("Add");
         }
         count++;  
       }
       else 
       {
         if(count == elements.length)
         {
           organizedHits.add(hit);
           System.out.println("Sub");
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
	 
	 boolean enterBiteOne = false;
	 boolean enterBiteTwo = false;
	 boolean exitBiteOne = false;
	 boolean exitBiteTwo = false;
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
			enterBiteOne = true;
		}
	 }
	 else
	 {
		exitBiteOne = true;
	 }
	 if (hitTwo.size() > 0)
	 {
		if (hitTwo.get(0).entry == false)
		{
        enterBiteTwo = true;
      }
   }
   else
   {
      exitBiteTwo = true;
   }
   
   while(!exitBiteOne || !exitBiteTwo)
   {
      if(exitBiteOne)
      {
        hit = false;
        initial = hitTwo.get(biteTwo++);
        if(biteTwo == hitTwo.size())
        {
          exitBiteTwo = true;
        }
      }
    else if (exitBiteTwo)
    {
        hit = false;
        initial = hitOne.get(biteOne++);
        if(biteOne == hitOne.size())
        {
          exitBiteOne = true;
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
            exitBiteOne = true;
          }
        }
        else
        {
          hit = false;
          initial = hitTwo.get(biteTwo++);
          if(biteTwo == hitTwo.size())
          {
            exitBiteTwo = true;
          }
        }
    }
    if(initial.entry == false)
    {
        if(enterBiteOne && enterBiteTwo)
        {
          if(hit)
          {
            enterBiteOne = false;
          }
          else
          {
            initial.normal = PVector.mult(initial.normal, -1);
            initial.entry = true;
            hits.add(initial);
            enterBiteTwo = false;
          }
        }
        else if(enterBiteOne & !enterBiteTwo)
        {
          hits.add(initial);
          enterBiteOne = false;
        }
        else
        {
          enterBiteTwo = false;
        }
      }
      else
      {
        if(!enterBiteOne && !enterBiteTwo)
        {
          if(hit)
          {
            hits.add(initial);
            enterBiteOne = true;
          }
          else
          {
            enterBiteTwo = true;
          }
        }
        else if(enterBiteTwo && !enterBiteOne)
        {
          enterBiteOne = true;
        }
        else
        {
          initial.normal = PVector.mult(initial.normal, -1);
          initial.entry = false;
          hits.add(initial);
          enterBiteTwo = true;
        }
      }
    }
    return hits;
  }
}
