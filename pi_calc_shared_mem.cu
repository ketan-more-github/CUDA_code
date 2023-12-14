#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define THD_PER_BLK 256
#define N 9000000
__global__ void pi_calc(double* aread )
{
        int myid = threadIdx.x+blockIdx.x*blockDim.x;
        double x,step;
	if(myid<N){
        	step = 1.0/(double)N;
        	x=(myid)*step;

        	aread[myid]= 4.0/(1.0+x*x);
	}

}

__global__ void sum_reduce(double *arr, double *sum)
{
	int myid=blockIdx.x*blockDim.x+threadIdx.x;
	int range= THD_PER_BLK/2;
	__shared__ double tmp[THD_PER_BLK];
	tmp[threadIdx.x]=0.0;
	if(myid<N)
	{
		tmp[threadIdx.x] = arr[myid];
		__syncthreads();
		while(range>0)
		{
	     		if(threadIdx.x<range){
				tmp[threadIdx.x] += tmp[threadIdx.x+range];
			}
			range=range/2;
			__syncthreads();
		}
		if(threadIdx.x==0)
		{
			sum[blockIdx.x]=tmp[threadIdx.x];
		}
	
	
	}

}

int main()
{

        double  pi;
        double *sum,*aread, *area_small_d ;

        int size=N*sizeof(double);
        double total=0.0;
        double exe_time;
        struct timeval stop_time, start_time;
	int thds_per_block= THD_PER_BLK;
	int num_blocks = (N/thds_per_block)+1;

        double step = 1.0/(double) N;
        //area = 0.0;

	sum= (double *)malloc(N*sizeof(double));

	cudaMalloc(&area_small_d, num_blocks*sizeof(double));

        gettimeofday(&start_time, NULL);

        cudaMalloc(&aread, size);


        pi_calc<<< num_blocks,thds_per_block >>>(aread);
	cudaDeviceSynchronize();

	sum_reduce<<< num_blocks, thds_per_block >>>(aread, area_small_d);

        cudaMemcpy(sum, area_small_d, num_blocks*sizeof(double), cudaMemcpyDeviceToHost);

        for(int i=0;i<num_blocks;i++){

                total+=sum[i];
        }

        gettimeofday(&stop_time, NULL);
        exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));

        pi = step*total;
        printf("\n Value of pi is = %.16lf\n Execution time is = %lf seconds\n", pi, exe_time);

}

