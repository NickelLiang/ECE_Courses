#ifndef BAR_H
#define BAR_H

#include <string>
#include "Foo.h"

using namespace std;

namespace potd {
    class Bar : public Foo {
        public:
            Bar(string str) : Foo(str) {
                f_ = new Foo(str);
            }
            Bar(const Bar & other);
            ~Bar();
            Bar & operator=(const Bar & other);
            string get_name(void);
        private:
            potd::Foo * f_;
    };
}

#endif
