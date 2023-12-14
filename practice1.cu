#include<stdio.h>
#include<stdlib.h>

__global__ void calc_square(int* md, int* pd)
{

        int myid =  threadIdx.x;

        pd[myid] =(md[myid])*(md[myid]);
}


int main()
{
	int size = 400 * sizeof(int);
	int a[400], aa[400],*md,*pd;
	int i=0;
	

	//Initialize the vectors
	for(i=0; i<400; i++ )
	{
		a[i] = i;
	}

	cudaMalloc(&md, size);
        cudaMemcpy(md, a, size, cudaMemcpyHostToDevice);


        cudaMalloc(&pd, size);

        dim3   DimGrid(1, 1);
        dim3   DimBlock(400, 1);


        calc_square<<< DimGrid,DimBlock >>>(md,pd);

        cudaMemcpy(aa, pd, size, cudaMemcpyDeviceToHost);



	//print the output
	for(i=0; i<400; i++ )
	{
		printf("\t%d",aa[i]);
	}	
}




