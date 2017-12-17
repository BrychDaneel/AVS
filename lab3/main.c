#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <omp.h>
#include <sys/time.h>


#define LEN 20000


int matrix[LEN][LEN];
int vector[LEN];

int res1[LEN];
int res2[LEN];


long long getTime(){
    struct timeval time;
    struct timezone tz;
    gettimeofday(&time, &tz);
    return time.tv_sec * 1000LL * 1000LL + time.tv_usec;
}


int main(int argc, char **argv){
	int len = atoi(argv[1]);

        srand(getTime());

        //printf("Random initialization\n\n");
        for (int i=0; i<len; i++)
            for (int ii=0; ii<len; ii++)
                matrix[i][ii] = rand();
        for (int i=0; i<len; i++)
            vector[i] = rand();

        long long timeStart = getTime();
        //printf("Direct multiplication\n");
        for (int i=0; i<len; i++){
            res1[i] = 0;
            for (int ii=0; ii<len; ii++)
                res1[i] += matrix[i][ii] * vector[i];
        }
        printf("%f\n", (getTime() - timeStart) / 1000. / 1000.);


        timeStart = getTime();
        //printf("Parallel multiplication\n");
        #pragma omp parallel for
        for (int i=0; i<len; i++){
            res1[i] = 0;
            for (int ii=0; ii<len; ii++)
                res1[i] += matrix[i][ii] * vector[i];
        }
        printf("%f\n", (getTime() - timeStart) / 1000. / 1000.);

        return 0;
}
