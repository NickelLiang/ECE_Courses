#ifndef _DERIVED_H
#define _DERIVED_H

#include <string>
#include "Base.h"

class Derived : public Base {
public:
    std::string foo();
    virtual std::string bar();
    virtual ~Derived();
};

#endif
