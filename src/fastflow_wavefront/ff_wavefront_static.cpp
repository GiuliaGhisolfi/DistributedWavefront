// FastFlow includes
#include "ff/ff.hpp"
#include "ff/parallel_for.hpp"

#include <vector>
#include <cmath>
#include <chrono>

using namespace ff;

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

// Compute a single element in the k-th diagonal
double compute_diagonal(int m, int k, const std::vector<std::vector<double>>& matrix) {
    double result = 0;
    for (int i = 0; i < k; ++i) {
        result += matrix[m][m + i] * matrix[m + k - i][m + k];
    }
    return std::cbrt(result); // cubic root of the result
}

// Initialize the matrix with the main diagonal
void initialize_matrix(int n, std::vector<std::vector<double>>& matrix, ParallelFor& pf, int chunk) {
    int step = 1;
    pf.parallel_for_static(0, n, step, chunk, [&](int i) {
        matrix[i][i] = (i + 1) / static_cast<double>(n);
    });
}

// Function to run the wavefront computation
int run_wavefront(const uint64_t &N, const uint32_t &T, const uint32_t &G) {
    // Allocate and initialize the matrix
    std::vector<std::vector<double>> matrix(N, std::vector<double>(N, 0.0));
    
    ParallelFor pf(T); // ParallelFor instance with T threads

    initialize_matrix(N, matrix, pf, G);

    // Compute wavefront for each diagonal
    auto start_time = std::chrono::high_resolution_clock::now();
    for (int k = 1; k < N; ++k) {
        int step = 1;
        pf.parallel_for_static(0, N - k, step, G, [&](int m) {
            matrix[m][m + k] = compute_diagonal(m, k, matrix);
        });
    }
    auto end_time = std::chrono::high_resolution_clock::now();

    // Measure and print elapsed time
    std::chrono::duration<double, std::milli> elapsed = end_time - start_time;
    std::printf("%.3f\n", elapsed.count());
    //std::printf("%.3f\n", matrix[0][N - 1]);

    return 0;
}

int main(int argc, char *argv[]) {
    // Check that exactly three arguments are provided (matrix size, threads, granularity)
    if (argc != 4) {
        std::printf("Error: Invalid number of arguments\n");
        return 1;
    }

    std::string arg_size = argv[1];
    uint64_t N = 0;
    std::string prefix = "--matrix_size=";
    if (arg_size.rfind(prefix, 0) == 0) {
        arg_size = arg_size.substr(prefix.size());  // Remove the prefix
    }

    std::string arg_threads = argv[2];
    uint32_t T = 0;
    std::string prefix_threads = "--threads=";
    if (arg_threads.rfind(prefix_threads, 0) == 0) {
        arg_threads = arg_threads.substr(prefix_threads.size());  // Remove the prefix
    }

    std::string arg_grain = argv[3];
    uint32_t G = 0;
    std::string prefix_grain = "--granularity=";
    if (arg_grain.rfind(prefix_grain, 0) == 0) {
        arg_grain = arg_grain.substr(prefix_grain.size());  // Remove the prefix
    }

    try {
        N = std::stoull(arg_size);
        T = std::stoul(arg_threads);
        G = std::stoul(arg_grain);
    } catch (const std::exception &e) {
        std::printf("Error: %s\n", e.what());
        return 1;
    }

    return run_wavefront(N, T, G);
}