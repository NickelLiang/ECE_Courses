#include <stdio.h>

int main() {
  int a = 5;
  int* b = &a;
  size_t c = (size_t)b;
  int** d = &b;
  int*** e = &d;
  printf("a is %d\n", a);
  printf("b is %p\n", b);
  printf("*b is %d\n", *b);
  printf("c is %zx\n", c);
  printf("d is %p\n", d);
  printf("*d is %p\n", *d);
  printf("**d is %d\n", **d);
  printf("***e is %d\n", ***e);
  return 0;
}
