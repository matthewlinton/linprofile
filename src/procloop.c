#include <stdlib.h>
#include <math.h>
#include <unistd.h>

// run an processor intensive loop

int main(int argc, char *argv[]) {
    double res = 5;
    double i = 5;
    while(1) {
        res = fmod(res, i);
        i = pow(res, i);
        res = exp(i);
        i = fmod(res, i);
        usleep(1);     // sleep for 1 micro second to let other processes do stuff
    }
}
