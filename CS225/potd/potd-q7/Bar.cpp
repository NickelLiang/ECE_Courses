#include "Bar.h"

using namespace potd;
using namespace std;

// Bar::Bar(string str) {
//     f_ = new Foo(str);
// }

Bar::Bar(const Bar & other) {
    // this->f_ = other.f_;
    f_ = new Foo(other.f_->get_name());
}

Bar::~Bar() {
    if (f_ != NULL) {
        f_->~Foo();
    }
}

Bar & Bar::operator=(const Bar & other) {
    this->f_ = other.f_;
    return *this;
}

string Bar::get_name() {
    return f_->get_name();
}
