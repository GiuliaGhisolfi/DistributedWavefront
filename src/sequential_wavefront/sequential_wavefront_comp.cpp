// Sequential code for wavefront computation using dot product.
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

// Sequential wavefront computation
void wavefront(std::vector<std::vector<double>> &matrix, const size_t N) {
    for (size_t k = 1; k < N; ++k) { // For each upper diagonal (excluding the main diagonal)
        for (size_t m = 0; m < N - k; ++m) { // For each element in the diagonal
            double result = 0;
            for (int i = 0; i < k; ++i) {
                result += matrix[m][m + i] * matrix[m + k - i][m + k];
            }
            matrix[m][m + k] = std::cbrt(result); // cubic root of the result
        }
    }
}

// Function to run the wavefront computation
int run_wavefront(const uint64_t &N) {
    // Allocate and initialize the matrix
    std::vector<std::vector<double>> matrix(N, std::vector<double>(N, 0.0));

    // Initialize the main diagonal
    for (size_t i = 0; i < N; ++i) {
        matrix[i][i] = (i + 1) / static_cast<double>(N);
    }

    // Start the wavefront computation
    auto start_time = std::chrono::high_resolution_clock::now();
    wavefront(matrix, N);
    auto end_time = std::chrono::high_resolution_clock::now();

    // Measure and print elapsed time
    std::chrono::duration<double, std::milli> elapsed = end_time - start_time;
    std::printf("%.3f", elapsed.count());
    //std::printf("\n%f", matrix[0][N - 1]);

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {  // Check that exactly one argument is provided
        std::printf("Usage: %s <matrix_size>\n", argv[0]);
        return 1;
    }

    std::string arg = argv[1];
    uint64_t N = 0;

    // Check if the argument starts with "--matrix_size="
    std::string prefix = "--matrix_size=";
    if (arg.rfind(prefix, 0) == 0) {
        arg = arg.substr(prefix.size());  // Remove the prefix
    }

    // Convert the remaining argument to a number
    try {
        N = std::stoull(arg);
    } catch (const std::exception &e) {
        std::printf("Error: Invalid matrix size. %s\n", e.what());
        return 1;
    }

    // Call the wavefront function
    return run_wavefront(N);
}