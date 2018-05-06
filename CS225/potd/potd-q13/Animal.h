// Animal.h
#ifndef _ANIMAL_H
#define _ANIMAL_H

#include <string>

using namespace std;

class Animal {
public:
    Animal();
    Animal(string t, string f);
    string getType();
    void setType(string s);
    string getFood();
    void setFood(string s);
    virtual string print();
private:
    string type_;
protected:
    string food_;
};

#endif
