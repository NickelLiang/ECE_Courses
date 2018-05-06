#ifndef _STUDENT_H
#define _STUDENT_H

#include <string>

namespace potd {
    class student {
    private:
        std::string name_;
        int grade_;
    public:
        std::string get_name(void);
        void set_name(std::string name);
        int get_grade(void);
        void set_grade(int grade);
        student();
        student(int grade, std::string name);
    };
}

#endif
