class Light
{
   PVector position;
   color diffuse;
   color specular;
   Light(PVector position, color col)
   {
     this.position = position;
     this.diffuse = col;
     this.specular = col;
   }
   
   Light(PVector position, color diffuse, color specular)
   {
     this.position = position;
     this.diffuse = diffuse;
     this.specular = specular;
   }
   
   color shine(color col)
   {
       return scaleColor(col, this.diffuse);
   }
   
   color spec(color col)
   {
       return scaleColor(col, this.specular);
   }
}

class LightingModel
{
    ArrayList<Light> lights;
    LightingModel(ArrayList<Light> lights)
    {
      this.lights = lights;
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      color surfacecol = lights.get(0).shine(hitcolor);
      PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();
      float intensity = PVector.dot(tolight, hit.normal);
      return lerpColor(color(0), surfacecol, intensity);
    }
  
}

class PhongLightingModel extends LightingModel
{
    color ambient;
    boolean withshadow;
    PhongLightingModel(ArrayList<Light> lights, boolean withshadow, color ambient)
    {
      super(lights);
      this.withshadow = withshadow;
      this.ambient = ambient;
      
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
		MaterialProperties matProp = hit.material.properties;
    	Material mat = hit.material;
    	color Color = mat.getColor(hit.u, hit.v);
	
	//L, R, V, N for calculation components of Phong
    
    	PVector L;
    	PVector R;
    	PVector V = PVector.sub(viewer, hit.location).normalize();
    	PVector N = hit.normal;
   
    	color Shine;
    	color Spec;
    	color end = multColor(scaleColor(Color, ambient), matProp.ka);

      	for(Light l : lights)
      	{
        	L = PVector.sub(l.position, hit.location).normalize();
			//Calculating for R
        	R = PVector.mult(N, (2 * PVector.dot(N, L)));
        	R = PVector.sub(R, L).normalize();

       	 	Ray sh = new Ray(PVector.add(hit.location, PVector.mult(L, EPS)), L);
        	ArrayList<RayHit> reflected = sc.root.intersect(sh);

        if (reflected.size() != 0 && withshadow)
        {
          RayHit reflectedHits = reflected.get(0);
          if (reflectedHits.t <= PVector.sub(l.position, hit.location).mag())
          {
            continue;
          }
        }

        Shine = multColor(l.shine(Color), matProp.kd);
        Shine = multColor(Shine, PVector.dot(L, N));
        Spec = multColor(l.spec(Color), matProp.ks);
        Spec = multColor(Spec, pow(PVector.dot(R, V), matProp.alpha));
        end = addColors(end, addColors(Spec, Shine));

      }

      return end;
   }
  
}
