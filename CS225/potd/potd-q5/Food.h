#ifndef _FOOD_H
#define _FOOD_H

#include <string>

class Food {
private:
    int quantity_;
    std::string name_;

public:
    Food();
    Food(int quantity, std::string name);
    void set_name(std::string name);
    std::string get_name(void);
    void set_quantity(int quantity);
    int get_quantity(void);
};

#endif
