class Shape {

  boolean moving, rotating, resizing;
  Body body;
  float w;
  float h;
  float a;
  Vec2 pos;
  PolygonShape sd;
  FixtureDef fd;

  // Constructor
  public Shape(float x_, float y_, float w_, float h_, float a_) {
    float x = x_;
    float y = y_;
    w = w_;
    h = h_;
    a = a_;
    // Add the box to the box2d world
    makeBody(new Vec2(x,y),w,h,a);
    moving = false;
    rotating = false;
    resizing = false;
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  boolean contains(float x, float y) {
    Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);
    Fixture f = body.getFixtureList();
    boolean inside = f.testPoint(worldPoint);
    return inside;
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    a = body.getAngle();
    
    if (moving) {
      body.setTransform(box2d.coordPixelsToWorld(new Vec2(mouseX, mouseY).sub(mousePos)), body.getAngle());
      //System.out.println(pos + " " + new Vec2(mouseX, mouseY));
    }
    if (rotating) {
      sight = new Vec2(mouseX-xTranslate-pos.x, mouseY-yTranslate-pos.y);
      a = PI/2 - atan(sight.y / sight.x);
      body.setTransform(box2d.coordPixelsToWorld(pos), a);
    }
    if (resizing) {
      sight = new Vec2(mouseX-xTranslate-pos.x, mouseY-yTranslate-pos.y);
      
      h = originalHeight -sight.y + mResize.y;
      float box2dW = box2d.scalarPixelsToWorld(w/2);
      float box2dH = box2d.scalarPixelsToWorld(h/2);
      sd.setAsBox(box2dW, box2dH);
      fd.shape = sd;
      body.createFixture(fd);
    }
    
    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    fill(150, 120, 80);
    stroke(175);
    rect(0,0,w,h);
    popMatrix();
  }
  
  void turn90() {
    body.setTransform(box2d.coordPixelsToWorld(pos), body.getAngle() + PI/2);
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_, float a_) {
    // Define and create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);

    // Define a polygon (this is what we use for a rectangle)
    sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);
    body.setTransform(box2d.coordPixelsToWorld(box2d.getBodyPixelCoord(body)), a_); //set angle
  }
  
  String toString() {
    return pos.x + "," + pos.y + "," + w + "," + h + "," + a;
  }
}
