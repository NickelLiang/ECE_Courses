// Pet.h
#ifndef _PET_H
#define _PET_H

#include "Animal.h"
#include <string>

using namespace std;

class Pet : public Animal {
private:
    string name_;
    string owner_name_;
public:
    Pet();
    Pet(string t, string f, string n, string o);
    void setFood(string nu_food);
    string getFood();
    void setName(string nu_name);
    string getName();
    void setOwnerName(string nu_owner_name);
    string getOwnerName();
    string print();
};

#endif
