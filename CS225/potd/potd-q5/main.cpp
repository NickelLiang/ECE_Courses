#include <iostream>
#include "Food.h"
#include "q5.h"

using namespace std;

int main() {
    // Food apple(5, "Apple");
    Food apple;
    apple.set_quantity(5);
    apple.set_name("Apple");
    cout << "You have " << apple.get_quantity() << " apples." << endl;
    increase_quantity(&apple);
    cout << "You have " << apple.get_quantity() << " apples." << endl;
    return 0;
}
