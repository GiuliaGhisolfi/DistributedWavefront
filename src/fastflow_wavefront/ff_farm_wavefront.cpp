// FastFlow includes
#include "ff/ff.hpp"
#include "ff/farm.hpp"

#include <vector>
#include <cmath>
#include <chrono>
#include <memory>
#include <iostream>
#include <thread>

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

// Worker class for diagonal elements computation
struct Worker : ff_node_t<std::tuple<int, int, int>, int> {
    std::vector<std::vector<double>> &matrix;

    Worker(std::vector<std::vector<double>> &m) : matrix(m) {}

    int *svc(std::tuple<int, int, int> *task) override {
        int k = std::get<0>(*task); // diagonal index
        int start = std::get<1>(*task); // start index
        int end = std::get<2>(*task); // end index

        for (int m = start; m < end; ++m) {
            double result = 0.0;

            // Compute the dot product of two vectors
            for (int i = 0; i < k; ++i) {
                result += matrix[m][m + i] * matrix[m + k - i][m + k];
            }
            result = std::cbrt(result); // cube root of the result
            matrix[m][m + k] = result; // store the result in the matrix

            // Send a completion signal to the emitter
            ff_send_out(new int(1));
        }

        delete task; // delete the task from heap
        return GO_ON;
    }
};

// Emitter class to distribute tasks
struct Emitter : ff_node_t<int, std::tuple<int, int, int>> {
    int N, chunk;
    int completedTasks = 0; // number of completed tasks
    int k = 1; // diagonal index

    Emitter(int n, int c) : N(n), chunk(c) {}

    std::tuple<int, int, int> *svc(int *task) {
        // Check if a task is completed
        if (task && *task == 1) {
            ++completedTasks; // increment the counter
            delete task;
        }

        // All tasks for the current diagonal are completed
        if (completedTasks == N - k) {
            completedTasks = 0; // reset the counter
            ++k; // move to the next diagonal

            if (k == N) { // all diagonals are computed
                return EOS;
            }
        }

        // Distribute tasks for the current diagonal
        if (completedTasks == 0) {
            for (int start = 0; start < N - k; start += chunk) {
                int end = std::min(start + chunk, N - k);
                ff_send_out(new std::tuple<int, int, int>(k, start, end));
            }
        }

        return GO_ON;
    }
};

// Initialize the matrix with the main diagonal
void initialize_matrix(int n, std::vector<std::vector<double>> &matrix) {
    for (int i = 0; i < n; ++i) {
        matrix[i][i] = (i + 1) / static_cast<double>(n);
    }
}

// Function to run the wavefront computation
int run_wavefront(const uint64_t &N, const uint32_t &T, const uint32_t &G) {
    // Allocate and initialize the matrix
    std::vector<std::vector<double>> matrix(N, std::vector<double>(N, 0.0));
    initialize_matrix(N, matrix);

    // Create emitter and workers
    Emitter emitter(N, G);

    std::vector<std::unique_ptr<ff_node>> workers;
    for (int i = 0; i < T; ++i) { // create T workers
        workers.push_back(std::make_unique<Worker>(matrix));
    }

    // Create the farm
    ff_Farm<> farm(std::move(workers));

    farm.add_emitter(emitter);
    farm.remove_collector();

    if (farm.wrap_around()) { // wrap-around to enable feedback from workers to emitter
        std::printf("Error: Cannot enable wrap-around\n");
        return 1;
    }

    // Compute wavefront for each diagonal
    auto start_time = std::chrono::high_resolution_clock::now();

    if (farm.run_and_wait_end() < 0) {
        std::printf("Error running farm\n");
        return 1;
    }

    auto end_time = std::chrono::high_resolution_clock::now();

    // Measure and print elapsed time
    std::chrono::duration<double, std::milli> elapsed = end_time - start_time;
    std::printf("%.3f\n", elapsed.count());
    //std::printf("%.3f\n", matrix[0][N - 1]);

    //print_matrix(matrix);

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        std::printf("Error: Invalid number of arguments\n");
        return 1;
    }

    std::string arg_size = argv[1];
    uint64_t N = 0;
    // Check if the argument starts with "--matrix_size="
    std::string prefix = "--matrix_size=";
    if (arg_size.rfind(prefix, 0) == 0) {
        arg_size = arg_size.substr(prefix.size());  // Remove the prefix
    }

    std::string arg_threads = argv[2];
    uint32_t T = 0;
    // Check if the argument starts with "--threads="
    std::string prefix_threads = "--threads=";
    if (arg_threads.rfind(prefix_threads, 0) == 0) {
        arg_threads = arg_threads.substr(prefix_threads.size());  // Remove the prefix
    }

    std::string arg_grain = argv[3];
    uint32_t G = 0;
    // Check if the argument starts with "--grain="
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