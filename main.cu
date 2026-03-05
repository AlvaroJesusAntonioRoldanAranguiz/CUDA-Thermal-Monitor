
#include <iostream>
#include <cuda_runtime.h>

// Kernel que simula el chequeo de 5 sensores en paralelo
__global__ void checkTemps(int* temps, bool* alerts) {
    int i = threadIdx.x; 
    if (temps[i] > 70) {
        alerts[i] = true; 
    } else {
        alerts[i] = false;
    }
}

int main() {
    int h_temps[5] = {65, 72, 68, 85, 60};
    bool h_alerts[5];

    int *d_temps;
    bool *d_alerts;

    // Memoria en GPU
    cudaMalloc(&d_temps, 5 * sizeof(int));
    cudaMalloc(&d_alerts, 5 * sizeof(bool));

    // Copiar al Device (GPU)
    cudaMemcpy(d_temps, h_temps, 5 * sizeof(int), cudaMemcpyHostToDevice);

    // Lanzar 5 hilos (un ejército de 5 núcleos)
    checkTemps<<<1, 5>>>(d_temps, d_alerts);

    // Traer resultados
    cudaMemcpy(h_alerts, d_alerts, 5 * sizeof(bool), cudaMemcpyDeviceToHost);

    for(int i=0; i<5; i++) {
        if(h_alerts[i]) std::cout << "Sensor " << i << ": ALERT! (" << h_temps[i] << "C)" << std::endl;
    }

    cudaFree(d_temps); cudaFree(d_alerts);
    return 0;
}
