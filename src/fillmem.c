#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

const char version[] = "1.2.0";
const char printhelpshort[] = "\
Usage: fillmem [-h] [-s size]\n\
Try fillmem -h for more information\n";
const char printhelplong[] = "\
Usage: fillmem [-h] [-s size]\n\
Arguments:\n\
    -h              Print out this help information.\n\
    -s <size>       Alter the size (KB) taken up by fillmem.\n\
                    Default 1KB.";

// Fill memory untill calloc breaks or we kill the process
int main(int argc, char *argv[]) {
    unsigned int scale = 128;
    unsigned int *p;
    unsigned int inc=1024*1024*sizeof(char);
    int carg = 0;

    // get command line arguments
    while ((carg = getopt(argc, argv, "hs")) != -1) {
        switch (carg) {
            case 'h':
                fprintf(stderr, printhelplong);
                return 0;
            case 's':
                if((unsigned int)optarg >= 0 && (unsigned int)optarg <= 1000000) {
                    scale = (unsigned int)optarg;
                }
                break;
            case '?':
                fprintf(stderr, printhelpshort);
                return 1;
        }
    }
    
    // allocate memory
    p = (unsigned int*) calloc(scale, inc);
    pause();    // just sit in memory untill we get killed
}
