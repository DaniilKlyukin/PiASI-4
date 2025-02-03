#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <string>
using namespace std;

cudaError_t piWithCuda(int iter3, double* piCuda);
int showGPU();
//расчетный алгоритм
__global__ void piIter(double* piCuda)
{
	//for (int k = 0; k <= *t - 1; k++)
	//{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
		piCuda[i] = 4.0 / (4.0 * (double)i + 1) - 4.0 / (4.0 * (double)i + 3);
	//}
}
double PiGPU2(int iter2)
{
	/*const int arraySize2 = 300000;
	//
	double c2[arraySize2] = { 0 };*/
	//iter2 = 10000;
	double Pi = 0;
	double *pi = new double[iter2];
	//double pi[1000000] = {};
	cudaError_t cudaStatus2 = piWithCuda(iter2, pi);
	for (int i = 0; i < iter2; i++) Pi += pi[i];
	cudaStatus2 = cudaDeviceReset();
	return Pi;
}
cudaError_t piWithCuda(int iter3, double* piCuda)
{
	//int* dev_iter = 0;
	double* dev_pi = 0;
	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);
	int threadsPerBlock = 1024;
	//int size = 100000;
	
	//cudaStatus = cudaMalloc((void**)&dev_iter, sizeof(int));
	cudaStatus = cudaMalloc((void**)&dev_pi, iter3 * sizeof(double));
	//cudaStatus = cudaMemcpy(dev_iter, &iter3, sizeof(int), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(dev_pi, piCuda, iter3 * sizeof(double), cudaMemcpyHostToDevice);
	int blocksPerGrid = (iter3 + threadsPerBlock - 1) / threadsPerBlock;
	piIter << <blocksPerGrid, threadsPerBlock >> > (dev_pi);
	cudaStatus = cudaDeviceSynchronize();
	cudaStatus = cudaMemcpy(piCuda, dev_pi, iter3 * sizeof(double), cudaMemcpyDeviceToHost);
	//cudaFree(dev_iter);
	cudaFree(dev_pi);
	return cudaStatus;
}
int showGPU()
{
	int deviceCount;
	cudaDeviceProp devProp;
	cudaGetDeviceCount(&deviceCount);
	string str = "";
	str += "Found devices: " + to_string(deviceCount) + " devices\n";
	for (int device = 0; device < deviceCount; device++)
	{
		cudaGetDeviceProperties(&devProp, device);
		str += "Device: " + to_string(device);
		str += "\nCompute capability: " + to_string(devProp.major) + "." + to_string(devProp.minor);
		str += "\nName: ";
		str += devProp.name;
		str += "\nTotal Global Memory: " + to_string(devProp.totalGlobalMem);
		str += "\nShared memory per block: " + to_string(devProp.sharedMemPerBlock);
		str += "\nRegisters per block: " + to_string(devProp.regsPerBlock);
		str += "\nWarp size: " + to_string(devProp.warpSize);
		str += "\nMax threads per block: " + to_string(devProp.maxThreadsPerBlock);
		str += "\nTotal constant memory: " + to_string(devProp.totalConstMem);
	}
	/*const char* msg = "Found devices: ";
	const char* msg2 = " Found2 devices: ";
	//char* sum = new char[strlen(msg) + strlen(msg2) + 1];
	//strcpy(sum, msg);
	//strcat(sum, msg2);
	char filename[] = "data.txt";
	// запись в файл
	FILE* fp = fopen(filename, "w");
	if (fp)
	{
		// записываем строку
		fputs(msg, fp);
		fclose(fp);
		//printf("File has been written\n");
	}

	delete[] msg;
	delete[] msg2;*/
	//С помощью переменной file будем осуществлять доступ к файлу
	char buf[1024];
	strcpy(buf, str.c_str());
	FILE* file;
	//Открываем текстовый файл с правами на запись
	file = fopen("test.txt", "w+t");
	//Пишем в файл
	fprintf(file, buf);
	//Закрываем файл
	fclose(file);
	return 0;
	/*string str;
	int deviceCount;
	cudaDeviceProp devProp;
	cudaGetDeviceCount(&deviceCount);
	str += "Found devices: " + to_string(deviceCount) + " devices.\n";
	for (int device = 0; device < deviceCount; device++)
	{
		cudaGetDeviceProperties(&devProp, device);
		str += "Device: " + to_string(device);
		str += "\nCompute capability: " + to_string(devProp.major) + "." + to_string(devProp.minor);
		str += "\nName ";
		str += devProp.name;
		str += "\nTotal Global Memory " + to_string(devProp.totalGlobalMem);
		str += "\nShared memory per block " + to_string(devProp.sharedMemPerBlock);
		str += "\nRegisters per block " + to_string(devProp.regsPerBlock);
		str += "\nWarp size " + to_string(devProp.warpSize);
		str += "\nMax threads per block " + to_string(devProp.maxThreadsPerBlock);
		str += "\nTotal constant memory " + to_string(devProp.totalConstMem);
	}
	return str;*/
	/*int deviceCount;
	cudaDeviceProp devProp;
	cudaGetDeviceCount(&deviceCount);
	printf("Found %d devices\n", deviceCount);
	for (int device = 0; device < deviceCount; device++)
	{
		cudaGetDeviceProperties(&devProp, device);
		printf("Device %d\n", device);
		printf("Compute capability     : %d.%d\n", devProp.major, devProp.minor);
		printf("Name                   : %s\n", devProp.name);
		printf("Total Global Memory    : %d\n", devProp.totalGlobalMem);
		printf("Shared memory per block: %d\n", devProp.sharedMemPerBlock);
		printf("Registers per block    : %d\n", devProp.regsPerBlock);
		printf("Warp size              : %d\n", devProp.warpSize);
		printf("Max threads per block  : %d\n", devProp.maxThreadsPerBlock);
		printf("Total constant memory  : %d\n", devProp.totalConstMem);
		//maxThreadsPerBlock = devProp.maxThreadsPerBlock;
	}*/
	/*return 0;

	// строка для записи
	char* message = str;
	// файл для записи
	char* filename = "data.txt";
	// запись в файл
	FILE* fp = fopen(filename, "w");
	if (fp)
	{
		// записываем строку
		fputs(message, fp);
		fclose(fp);
		printf("File has been written\n");
	}*/
}