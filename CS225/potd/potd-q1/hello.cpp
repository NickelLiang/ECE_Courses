/* Your code here! */
#include "hello.h"

std::string hello() {
    std::string myName = "Nickel";
    int myAge = 19;
    std::string output = std::string("Hello world! My name is ") + myName;
    output += " and I am ";
    output += std::to_string(myAge);
    output += " years old.";
    return output;
}
