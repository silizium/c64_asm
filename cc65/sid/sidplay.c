#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <c64.h>

extern int setupAndStartPlayer();

int main(void) {
        printf("Setting up player\n");
        setupAndStartPlayer();
        return 0;
}
