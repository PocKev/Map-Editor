import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Box2DProcessing box2d;
ArrayList<Shape> shapes;
Vec2 mousePos, sight, mDrag, mResize, middle;
float originalHeight;

boolean dragging;
boolean inAction;
float xTranslate = 0, yTranslate = 0;

PrintWriter output;

void setup() {
  size(600, 400);
  smooth();
  //noCursor();
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  shapes = new ArrayList<Shape>();
  mousePos = new Vec2(0, 0);
  mDrag = new Vec2(0, 0);
  mResize = new Vec2(0, 0);
  middle = new Vec2(width/2, height/2);
  inAction = false;
  dragging = false;
}

void draw() {
  background(0);
  fill(175);
  pushMatrix();
  translate(xTranslate, yTranslate);
  if (dragging) {
    xTranslate = mouseX + mDrag.x - width/2;
    yTranslate = mouseY + mDrag.y - height/2;
    middle = new Vec2(xTranslate + width/2, yTranslate + height/2); //redefine position of middle
  }
  stroke(175);
  line(1, 1, 4*width, 1);
  line(1, 1, 1, 4*height);
  for (Shape shape : shapes) {
    shape.display();
  }
  popMatrix();
  
  //text("Q - Create\nW - Delete\nR - Rotate\nE - Rotate 90\nD - Drag\nS - Save", 5*width/6, 4.5*height/6);
  point(mouseX - xTranslate, mouseY - yTranslate);
  text((mouseX - xTranslate) + ", " + (mouseY - yTranslate), mouseX+15, mouseY-15);

  box2d.step();
}

//--------------INPUTS---------------

void keyPressed() {
  switch(key) {
    case 'q': //Create Shape
      shapes.add(new Shape(mouseX-xTranslate, mouseY-yTranslate, 15, 150, 0));
      System.out.println("Created shape: x = " + mouseX + ", y = " + mouseY);
      break;
    case 'w': //Delete Shape
      for (int i = 0; i < shapes.size(); i++) {
        if (shapes.get(i).contains(mouseX, mouseY) && !inAction) {
          shapes.get(i).killBody();
          shapes.remove(i);
        }
      }
      break;
    case 'r': //Rotate Shape
      for (Shape shape : shapes) {
        if (shape.contains(mouseX-xTranslate, mouseY-yTranslate) && !inAction) {
          shape.rotating = true;
          inAction = true;
          //sight = new Vec2(mouseX-shape.pos.x, mouseY-shape.pos.y);
        }
      }
      break;
    case 'e': //Rotate 90 degrees
      for (Shape shape : shapes) {
        if (shape.contains(mouseX-xTranslate, mouseY-yTranslate) && !inAction) {
          shape.turn90();
        }
      }
      break;
    case 'd': //Drag screen
      if (!inAction) {
        inAction = true;
        dragging = true;
        mDrag = new Vec2(middle.x - mouseX, middle.y - mouseY);
      }
      break;
    case 's': //Save file
      saveMap();
      break;
    case 'l': //Load file
      loadMap();
      break;
    case 'k': //clear map
      clearMap();
      break;
    case 'c': //Reset / Center screen
      middle = new Vec2(width/2, height/2);
      mDrag = new Vec2(middle.x - mouseX, middle.y - mouseY);
      xTranslate = mouseX + mDrag.x - width/2;
      yTranslate = mouseY + mDrag.y - height/2;
      break;
    case 'a': //resize shape
      for (Shape shape : shapes) {
        if (shape.contains(mouseX-xTranslate, mouseY-yTranslate) && !inAction) {
          shape.resizing = true;
          inAction = true;
          mResize = new Vec2(mouseX-xTranslate-shape.pos.x, mouseY-yTranslate-shape.pos.y);
          originalHeight = shape.h;
          //mResize = new Vec2(shape.pos.x, shape.pos.y);
        }
      }
      break;
  }
} // -----------end keyPressed()---------------

void keyReleased() {
  switch(key) {
    case 'd': //drag
      inAction = false;
      dragging = false;
      break;
    case 'r': //rotate
      for (Shape shape : shapes) {
        shape.rotating = false;
      }
      inAction = false;
      break;
    case 'a': //resize
      for (Shape shape : shapes) {
        shape.resizing = false;
      }
      inAction = false;
  }
}

void mousePressed() {
  //System.out.println(mouseX + " " + mouseY);
  for (Shape shape : shapes) {
    if (shape.contains(mouseX-xTranslate, mouseY-yTranslate) && !inAction) {
      shape.moving = true;
      inAction = true;
      mousePos = new Vec2(mouseX-shape.pos.x, mouseY-shape.pos.y);
    }
  }
}

void mouseReleased() {
  for (Shape shape : shapes) {
    shape.moving = false;
    inAction = false;
  }
} //-------------------End inputs, Next: Helper Methods----------------

void saveMap() {
  output = createWriter("mapFile.txt"); //output text file
  for (Shape shape : shapes) {
    output.println(shape);
  }
  output.flush();
  output.close();
  System.out.println("saved");
}

void loadMap() {
  clearMap();
  String[] lines = loadStrings("mapFile.txt"); //get all lines, store it into an array
  for (int i = 0; i < lines.length; i++) {
    float[] args = float(split(lines[i], ',')); //reading each line
    shapes.add(new Shape(args[0], args[1], args[2], args[3], args[4])); //creates a new shape stored in file
  }
  System.out.println("loaded");
}

void clearMap() {
  for (int i = 0; i < shapes.size();) {
    shapes.get(i).killBody();
    shapes.remove(i);
  }
  System.out.println("cleared");
}
