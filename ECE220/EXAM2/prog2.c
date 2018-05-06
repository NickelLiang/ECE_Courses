#include <stdio.h>

void permutation(char *s, int left, int right);
void swap(char *a, char *b);

int main(int argc, char const *argv[]) {
    char str[] = "DEF";
    permutation(str, 0, 2);
    return 0;
}


void permutation(char *s, int left, int right) {
    int i;
    if (left == right) {
        printf("%s\n", s);
    } else {
        for (i = left; i <= right; i++) {
            swap(&s[i], &s[left]);
            permutation(s, left+1, right);
            swap(&s[left], &s[i]);
        }
    }
}

void swap(char *a, char *b) {
    char temp = *a;
    *a = *b;
    *b = temp;
}
