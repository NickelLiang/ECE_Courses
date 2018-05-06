#include "shape.hpp"

#define PI 3.1415926

//Base class
//Please implement Shape's member functions
//constructor, getName()
//Base class' constructor should be called in derived classes'
//constructor to initizlize Shape's private variable
Shape::Shape(string name) {name_ = name;}
string Shape::getName() {return name_;}

//Rectangle
//Please implement the member functions of Rectangle:
//constructor, getArea(), getVolume(), operator+, operator-
Rectangle::Rectangle(double width, double length) : Shape("Rectangle") {
    width_ = width;
    length_ = length;
}
double Rectangle::getArea() const {return width_ * length_;}
double Rectangle::getVolume() const {return 0;}
Rectangle Rectangle::operator + (const Rectangle& rec) {
    return Rectangle(width_+rec.getWidth(), length_+rec.getLength());
}
Rectangle Rectangle::operator - (const Rectangle& rec) {
    return Rectangle(max(0.0,width_-rec.getWidth()), max(0.0,length_-rec.getLength()));
}
double Rectangle::getWidth() const {return width_;}
double Rectangle::getLength() const {return length_;}

//Circle
//Please implement the member functions of Circle:
//constructor, getArea(), getVolume(), operator+, operator-
Circle::Circle(double radius) : Shape("Circle") {radius_ = radius;}
double Circle::getArea() const {return radius_ * radius_ * PI;}
double Circle::getVolume() const {return 0;}
Circle Circle::operator + (const Circle& cir) {
    return Circle(radius_+cir.getRadius());
}
Circle Circle::operator - (const Circle& cir) {
    return Circle(max(0.0,radius_-cir.getRadius()));
}
double Circle::getRadius() const {return radius_;}

//Sphere
//Please implement the member functions of Sphere:
//constructor, getArea(), getVolume(), operator+, operator-
Sphere::Sphere(double radius) : Shape("Sphere") {radius_ = radius;}
double Sphere::getArea() const {return 4 * radius_ * radius_ * PI;}
double Sphere::getVolume() const {return (4.0 / 3.0) * radius_ * radius_ * radius_ * PI;}
Sphere Sphere::operator + (const Sphere& sph) {
    return Sphere(radius_+sph.getRadius());
}
Sphere Sphere::operator - (const Sphere& sph) {
    return Sphere(max(0.0,radius_-sph.getRadius()));
}
double Sphere::getRadius() const {return radius_;}

//Rectprism
//Please implement the member functions of RectPrism:
//constructor, getArea(), getVolume(), operator+, operator-
RectPrism::RectPrism(double width, double length, double height) : Shape("RectPrism") {
    width_ = width;
    length_ = length;
    height_ = height;
}
double RectPrism::getArea() const {
    return 2 * (length_ * width_ + length_ * height_ + width_ * height_);
}
double RectPrism::getVolume() const {return length_ * width_ * height_;}
RectPrism RectPrism::operator + (const RectPrism& rectp) {
    double newWidth = width_+rectp.getWidth();
    double newLength = length_+rectp.getLength();
    double newHeight = height_+rectp.getHeight();
    return RectPrism(newWidth, newLength, newHeight);
}
RectPrism RectPrism::operator - (const RectPrism& rectp) {
    double newWidth = max(0.0, width_-rectp.getWidth());
    double newLength = max(0.0, length_-rectp.getLength());
    double newHeight = max(0.0, height_-rectp.getHeight());
    return RectPrism(newWidth, newLength, newHeight);
}
double RectPrism::getWidth() const {return width_;}
double RectPrism::getHeight() const {return height_;}
double RectPrism::getLength() const {return length_;}

// Read shapes from test.txt and initialize the objects
// Return a vector of pointers that points to the objects
vector<Shape*> CreateShapes(char* file_name) {
	ifstream ifs(file_name, ifstream::in);
    vector<Shape*> shapePtr = vector<Shape*>();
    int size = 0;
    ifs >> size;
    for(int i = 0; i < size; i++) {
		string shapeIs;
		ifs >> shapeIs;
        Shape* newShape;
        // cout << "Shape is " << shapeIs << endl;
        if (shapeIs == "Rectangle") {
            double width, height;
            ifs >> width >> height;
            newShape = new Rectangle(width, height);
        } else if (shapeIs == "Circle") {
            double radius;
            ifs >> radius;
            newShape = new Circle(radius);
        } else if (shapeIs == "Sphere") {
            double radius;
            ifs >> radius;
            newShape = new Sphere(radius);
        } else if (shapeIs == "RectPrism") {
            double width, length, height;
            ifs >> width >> length >> height;
            newShape = new RectPrism(width, length, height);
        } else {
            break;
        }
		shapePtr.push_back(newShape);
	}
	return shapePtr;
}

// call getArea() of each object
// return the max area
double MaxArea(vector<Shape*> shapes) {
	double max_area = 0;
    for(int i = 0; i < (int)(shapes.size()); i++){
		double area = shapes[i]->getArea();
        string shape = shapes[i]->getName();
        // cout << "Shape " << shape << " Area " << area << endl;
        if (area > max_area) {
            max_area = area;
        }
	}
	return max_area;
}

// call getVolume() of each object
// return the max volume
double MaxVolume(vector<Shape*> shapes) {
	double max_volume = 0;
    for(int i = 0; i < (int)(shapes.size()); i++){
        double volume = shapes[i]->getVolume();
        string shape = shapes[i]->getName();
        // cout << "Shape " << shape << " Volume " << volume << endl;
        if (volume > max_volume) {
            max_volume = volume;
        }
    }
	return max_volume;
}
