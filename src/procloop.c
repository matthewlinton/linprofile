#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>

const char version[] = "1.2.0";
const char printhelpshort[] = "\
Usage: procloop [-h] [-s microseconds]\n\
Try procloop -h for more information\n";
const char printhelplong[] = "\
Usage: procloop [-h] [-s microseconds]\n\
Arguments:\n\
    -h              Print out this help information.\n\
    -s <usec>       Sleep for the number of microseconds specified.\n\
                    This can be between 1 - 1000000. default 1 second.\n";

// run an processor intensive loop
int main(int argc, char *argv[]) {
    unsigned int sleep = 1000000;      // microseconds to sleep
    int carg = 0;
    double res = 5;
    double i = 5;

    // get command line arguments
    while ((carg = getopt(argc, argv, "hs")) != -1) {
        switch (carg) {
            case 'h':
                fprintf(stderr, printhelplong);
                return 0;
            case 's':
                if((unsigned int)optarg >= 0 && (unsigned int)optarg <= 1000000) {
                    sleep = (unsigned int)optarg;
                }
                break;
            case '?':
                fprintf(stderr, printhelpshort);
                return 1;
        }
    }

    // Tie up the processor 
    while(1) {
        res = fmod(res, i);
        i = pow(res, i);
        res = exp(i);
        i = fmod(res, i);
        usleep(sleep);
    }
}
