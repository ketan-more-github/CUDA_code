#include"stdio.h"
#include"stdlib.h"


#define N 100

__global__ void arradd(int* a, int* b, int* c)
{
        int myid = blockIdx.x*blockDim.x + threadIdx.x;
	if(myid<N){
		for(int j=0; j<N; j++){

			c[myid] += a[myid*N+j] * b[j];
		}
	}
}



int main(int argc, char **argv)
{
        int *A, *B, *C;
	int i,j;
        int *a,*b, *c;
        int flag = 0;

        B = (int *) malloc(N*sizeof(int));
        A = (int *) malloc(N*N*sizeof(int));
       	C = (int *) malloc(N*sizeof(int));
       	for(i=0;i<N;i++)
        {
            for(j=0;j<N;j++)
            {
                 A[i*N+j] = 1;
            }
                B[i] = 1;
                C[i] = 0;
        }
      

        cudaMalloc(&a, N*N*sizeof(int));
        cudaMemcpy(a, A, N*N*sizeof(int), cudaMemcpyHostToDevice);

        cudaMalloc(&b, N*sizeof(int));
        cudaMemcpy(b, B, N*sizeof(int), cudaMemcpyHostToDevice);

        cudaMalloc(&c, N*sizeof(int));

        dim3   DimGrid(1, 1);
        dim3   DimBlock(100, 1);

        arradd<<< DimGrid,DimBlock >>>(a,b,c);
	
        cudaMemcpy(C, c, N*sizeof(int), cudaMemcpyDeviceToHost);

	/*
        for(i=0;i<N/size;i++)
        {
            c[i] = 0;
            for(j=0;j<N;j++)
            {
                c[i] += a[i*N+j] * B[j];
            }
        }
	*/

        
       for(i=0;i<N;i++)
       {
          if(C[i] != N)
          {
              flag = 1;
              printf("\n %d", C[i]);
              break;
          }
      }

	if(flag == 0)
        {
              printf("\n PASS!\n");
        }
        else
        {
             printf("\n FAIL!\n");
        }

}

