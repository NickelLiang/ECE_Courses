#include "thing.h"

using namespace potd;
using namespace std;

Thing::Thing(int size) {
    props_ct_ = size;
    props_max_ = size;
    properties_ = new string[size];
    values_ = new string[size];
}

Thing::Thing(const Thing & other) {
    this->_copy(other);
}

Thing & Thing::operator=(const Thing & other) {
    this->_copy(other);
    return *this;
}

Thing::~Thing() {
    _destroy();
}

int Thing::set_property(string name, string value) {
    for (int i = 0; i < props_max_; i++) {
        if (properties_[i] == name) {
            values_[i] = value;
            return i;
        } else if (properties_[i] == "") {
            properties_[i] = name;
            values_[i] = value;
            return i;
        }
    }
    return -1;
}

string Thing::get_property(string name) {
    for (int i = 0; i < props_max_; i++) {
        if (properties_[i] == name) {
            return values_[i];
        }
    }
    return "";
}

void Thing::_copy(const Thing & other) {
    props_ct_ = other.props_ct_;
    props_max_ = other.props_max_;
    _destroy();
    properties_ = new string[props_max_];
    values_ = new string[props_max_];
    for (int i = 0; i < props_max_; i++) {
        properties_[i] = other.properties_[i];
        values_[i] = other.values_[i];
    }
}

void Thing::_destroy() {
    delete[] properties_;
    delete[] values_;
}
