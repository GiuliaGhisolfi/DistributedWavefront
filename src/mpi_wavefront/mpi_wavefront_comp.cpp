// Parallel wavefront computation using MPI
#include <mpi.h>
#include <iostream>
#include <vector>
#include <cmath>
#include <cassert>
#include <chrono>
#include <string>

void print_matrix(const std::vector<std::vector<double>>& matrix) {
    std::printf("\n");
    for (const auto& row : matrix) {
        for (const auto& elem : row) {
            std::printf("%.2f ", elem);
        }
        std::printf("\n");
    }
    std::printf("\n");
}

void initialize_matrix(std::vector<std::vector<double>> &matrix, const size_t N) {
    for (size_t i = 0; i < N; ++i) {
        for (size_t j = 0; j < N; ++j) {
            matrix[i][j] = 0.0;
        }
        matrix[i][i] = (i + 1) / static_cast<double>(N);
    }
}

void wavefront(std::vector<std::vector<double>> &matrix, const size_t N, int rank, int size) {
    for (size_t k = 1; k < N; ++k) { // k: wavefront index (diagonal index)
        int local_N = (rank == size - 1) ? (N - k) - (size - 1) * ((N - k) / size) : (N - k) / size;
        int start = rank * (N - k) / size;
        int end = start + local_N;

        // Local computation
        std::vector<double> local_results(local_N, 0.0);
        for (size_t m = start; m < end; ++m) { // m: row index
            double result = 0.0;
            #pragma omp simd reduction(+:result) // parallelize the inner loop
            for (int i = 0; i < k; ++i) { // i: column index
                if ((m + i) < N && (m + k - i) < N) {
                    result += matrix[m][m + i] * matrix[m + k - i][m + k];
                }
            }
            local_results[m - start] = std::cbrt(result);
        }

        // Collect results from all processes
        std::vector<int> receive_counts(size); // number of elements to receive from each process
        std::vector<int> displacement(size); // displacement of each process in the receive buffer

        for (int i = 0; i < size; i++) {
            receive_counts[i] = (i == size - 1) ? (N - k) - (size - 1) * ((N - k) / size) : (N - k) / size;
            displacement[i] = (i == 0) ? 0 : displacement[i - 1] + receive_counts[i - 1];
        }

        std::vector<double> global_results(N - k, 0.0);
        // Gather results from all processes
        MPI_Allgatherv(local_results.data(), (end - start), MPI_DOUBLE, global_results.data(),
        receive_counts.data(), displacement.data(), MPI_DOUBLE, MPI_COMM_WORLD);

        // Update matrix with aggregated results
        #pragma omp parallel for simd // parallelize the loop with OpenMP
        for (size_t m = 0; m < N - k; ++m) {
            matrix[m][m + k] = global_results[m];
        }
    }
}

int main(int argc, char *argv[]) {
    MPI_Init(&argc, &argv);

    // Get the rank and size of the MPI communicator
    int rank, size; // rank: process id, size: number of processes
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (argc != 2) {
        if (rank == 0) {
            std::printf("Error: Invalid number of arguments\n");
        }
        MPI_Finalize();
        return 1;
    }

    size_t N = std::stoul(argv[1]);

    // Allocate and initialize the matrix
    std::vector<std::vector<double>> matrix(N, std::vector<double>(N));
    initialize_matrix(matrix, N);

    auto start_time = std::chrono::high_resolution_clock::now();

    wavefront(matrix, N, rank, size);

    auto end_time = std::chrono::high_resolution_clock::now();

    // Print the elapsed time
    if (rank == 0) {
        std::chrono::duration<double, std::milli> elapsed = end_time - start_time;
        std::printf("%.3f\n", elapsed.count());
        //std::printf("%.3f\n", matrix[0][N - 1]);
        
        //print_matrix(matrix);
    }

    MPI_Finalize();
    return 0;
}
