#include<stdio.h>
#include<stdlib.h>

void my_cudasafe( cudaError_t error, char* message)
{
        if(error!=cudaSuccess)
        {
                fprintf(stderr,"ERROR: %s : %s\n",message,cudaGetErrorString(error));
                exit(-1);
        }
}



__global__ void arrmul(double* md, double* nd, double* pd, double alpha )
{
        int myid = threadIdx.x+blockIdx.x*blockDim.x;

        pd[myid] = md[myid] + alpha*nd[myid]; 
}

int main()
{
	int size = 400 * sizeof(double);
	double a[400], b[400], c[400], alpha;
	double *md, *nd,*pd;
	int i=0;
	
	alpha = 0.001;

	for(i=0; i<400; i++ )
	{
		a[i] = i;
		b[i] = i;
		c[i] = 0;
	}

        //cudaMemcpy(alpha, alpha, 4 , cudaMemcpyHostToDevice);

        my_cudasafe(cudaMalloc(&md, size), "Hi");
        my_cudasafe(cudaMemcpy(md, a, size, cudaMemcpyHostToDevice),"bye");

        my_cudasafe(cudaMalloc(&nd, size),"hii");
        my_cudasafe(cudaMemcpy(nd, b, size, cudaMemcpyHostToDevice),"hiii");

        my_cudasafe(cudaMalloc(&pd, size),"Byee");
	
	dim3   DimGrid(1, 1);
        dim3   DimBlock(400, 1);


        arrmul<<< DimGrid,DimBlock >>>(md,nd,pd,alpha);

        my_cudasafe(cudaMemcpy(c, pd, size, cudaMemcpyDeviceToHost),"heeee");

        for(i=0; i<400; i++ )
        {
                printf("\t%lf",c[i]);
        }

        cudaFree(md);
        cudaFree(nd);
        cudaFree(pd);

}
