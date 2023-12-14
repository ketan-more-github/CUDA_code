#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define N 10000
#define THD_PER_BLK 1024
/*
                N  PRIME_NUMBER

                1           0
               10           4
              100          25
            1,000         168
           10,000       1,229
          100,000       9,592
        1,000,000      78,498
       10,000,000     664,579
      100,000,000   5,761,455
    1,000,000,000  50,847,534

*/

__global__ void prime_calc(int* countarr)
{
        int myid = threadIdx.x+blockIdx.x*blockDim.x;
        int flag;
        if(myid<N){
                flag = 1;
                for(int j=2;j<myid;j++)
            	{
                    if((myid%j) == 0)
                    {
                            flag = 0;
                            break;
                    }
            	}
		if(myid>2){
        		countarr[myid]=flag;
		}

        }	

}
__global__ void count_reduce(int *countarr, int *sum)
{
        int myid=blockIdx.x*blockDim.x+threadIdx.x;
        int range= THD_PER_BLK/2;
        __shared__ int tmp[THD_PER_BLK];
        tmp[threadIdx.x]=0;
        if(myid<N)
        {
                tmp[threadIdx.x] =countarr[myid];
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
	int *countarr, *sum, *sum_d;
	double exe_time;
	int thds_per_block= THD_PER_BLK;
        int num_blocks = (N/thds_per_block)+1;
	int size=N*sizeof(int);
	sum= (int *)malloc(N*sizeof(int));
	struct timeval stop_time, start_time;
	
	int count = 1; // 2 is prime. Our loop starts from 3
	
	gettimeofday(&start_time, NULL);
	
	/*
	for(i=3;i<N;i++)
	{
	 	flag = 0;
		for(j=2;j<i;j++)	
	    {
		    if((i%j) == 0)
		    {
			    flag = 1;
			    break;
		    }
	    }
        if(flag == 0)
        {
        	count++;
        }
	}
	*/
	cudaMalloc(&sum_d, num_blocks*sizeof(int));
	cudaMalloc(&countarr, size);

	prime_calc<<< num_blocks,thds_per_block >>>(countarr);
	cudaDeviceSynchronize();
	
	count_reduce<<< num_blocks, thds_per_block >>>(countarr, sum_d);

	cudaMemcpy(sum, sum_d, num_blocks*sizeof(int), cudaMemcpyDeviceToHost);
	
	for(int i=0;i<num_blocks;i++){

                count+=sum[i];
		//printf("%d ",sum[i]);
        }

	gettimeofday(&stop_time, NULL);	
	exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));
	
	printf("\n Number of prime numbers = %d \n Execution time is = %lf seconds\n", count, exe_time);
	
}
