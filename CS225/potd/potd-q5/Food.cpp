#include "Food.h"

Food::Food() {}

Food::Food(int quantity, std::string name) {
    quantity_ = quantity;
    name_ = name;
}

void Food::set_name(std::string name) {
    name_ = name;
}

std::string Food::get_name(void) {
    return name_;
}

void Food::set_quantity(int quantity) {
    quantity_ = quantity;
}

int Food::get_quantity(void) {
    return quantity_;
}
