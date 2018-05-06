#include "q6.h"
#include "student.h"
#include <iostream>

using namespace potd;

int main() {
    student nickel(5, "Nickel");
    std::cout << nickel.get_name() << " is in grade " << nickel.get_grade() << std::endl;
    graduate(nickel);
    std::cout << nickel.get_name() << " is in grade " << nickel.get_grade() << std::endl;
    return 0;
}
