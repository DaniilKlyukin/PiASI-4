#include "cu1.h"
#include <string>
using namespace std;
extern "C"
__declspec (dllexport) double __cdecl PiGPU(int iter) {
	return PiGPU2(iter);
}
extern "C"
__declspec (dllexport) int __cdecl GPUInfo() {
	return showGPU();
}

