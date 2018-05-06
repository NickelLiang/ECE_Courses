#include "student.h"

std::string potd::student::get_name(void) {
    return name_;
}

void potd::student::set_name(std::string name) {
    name_ = name;
}

int potd::student::get_grade(void) {
    return grade_;
}

void potd::student::set_grade(int grade) {
    grade_ = grade;
}

potd::student::student() {
    name_ = "";
    grade_ = 0;
}

potd::student::student(int grade, std::string name) {
    grade_ = grade;
    name_ = name;
}
