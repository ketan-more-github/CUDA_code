#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>



__global__ void pi_calc(double dx, double* aread )
{
        int myid = threadIdx.x+blockIdx.x*blockDim.x;
        double y,x=0.0;
        x = myid*dx;
        y = sqrt(1-x*x);

        aread[myid]= y*dx;

}

int main()
{
        double area[400], pi;
        double* aread;

        int size=400*sizeof(double);
        double dx,total=0.0;
        double exe_time;
        struct timeval stop_time, start_time;

        dx = 1.0/400;
        //area = 0.0;

        gettimeofday(&start_time, NULL);

        cudaMalloc(&aread, size);

        dim3   DimGrid(1, 1);
        dim3   DimBlock(400, 1);


        pi_calc<<< DimGrid,DimBlock >>>(dx,aread);

        cudaMemcpy(&area, aread, size, cudaMemcpyDeviceToHost);

        for(int i=0;i<400;i++){

                total+=area[i];
        }

        gettimeofday(&stop_time, NULL);
        exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));

        pi = 4.0*total;
        printf("\n Value of pi is = %.16lf\n Execution time is = %lf seconds\n", pi, exe_time);

}

