#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

// Fill memory untill calloc breaks or we kill the process

int main(int argc, char *argv[]) {
    int scale = 128;
    int *p;
    int inc=1024*1024*sizeof(char);
    
    if ( argc >= 2 ) {
        scale = atoi(argv[1]);
    }

    p = (int*) calloc(scale, inc);
    pause();    // just sit in memory untill we get killed
}
