# Distributed Wavefront Computation

This repository contains the implementation of the Distributed Wavefront Computation.

The goal is to compute the elements of a matrix diagonally using a wavefront computation pattern while leveraging parallelism for efficiency. Additionally, the project evaluates performance in terms of speedup, scalability, and efficiency.


## 🔍 Project Overview

This project explores **parallelization strategies** for optimizing wavefront computation, which follows an **upper-triangular pattern** where elements on the same diagonal can be computed independently, while different diagonals must be processed sequentially.

The implementation includes:
- **Multi-threaded versions** using **FastFlow**, with:
  - **Data parallelism**: parallel-for with static anddynamic task scheduling
  - **Stream parallelism**: farm model for task distribution
- **Multi-process version** using **MPI**, designed for distributed execution on a cluster of multi-core machines.
- **Sequential implementation** is also provided as a baseline for performance evaluation.


## 🚀 Running Tests

### 🏗️ Compilation
First, compile the project using:
```bash
make
```

### 🔬 Running Individual Tests

#### **FastFlow Implementations**
- **Parallel-For Static Scheduling**
  ```bash
  src/fastflow_wavefront/ff_wavefront_static.exe --matrix_size=2048 --threads=2 --granularity=1
  ```
- **Parallel-For Dynamic Scheduling**
  ```bash
  src/fastflow_wavefront/ff_wavefront_dynamic.exe --matrix_size=2048 --threads=2 --granularity=1
  ```
- **Farm Model**
  ```bash
  src/fastflow_wavefront/ff_farm_wavefront.exe --matrix_size=2048 --threads=2 --granularity=1
  ```

#### **Sequential Implementation**
```bash
src/sequential_wavefront/sequential_wavefront_comp.exe --matrix_size=2048
```

#### **MPI Implementation**
```bash
mpirun -np 1 src/mpi_wavefront/mpi_wavefront.exe 2048
```

### 🔄 Clean Up
To remove compiled files:
```bash
make clean
```


## 🖥️ Running Tests via Scripts

Instead of running each test manually, you can use the provided **Bash scripts**:

- **Run all FastFlow tests**
  ```bash
  script_bash/ff_wavefront.sh
  ```
- **Run farm model**
  ```bash
  script_bash/ff_farm_wavefront.sh
  ```
- **Run MPI implementation**
  ```bash
  script_bash/mpi_wavefront.sh
  ```
- **Run sequential version**
  ```bash
  script_bash/sequential_wavefront.sh
  ```


## 🔬 Performance Testing with SLURM

This section provides instructions for running performance tests using **SLURM batch jobs**.

### **FastFlow Tests**
```bash
sbatch scripts_slurm/test_scalability_ff_dynamic.slurm
sbatch scripts_slurm/test_scalability_ff_farm.slurm
sbatch scripts_slurm/test_scalability_ff_static.slurm
```

### **MPI Tests**
```bash
sbatch scripts_slurm/test_mpi.slurm
sbatch scripts_slurm/test_mpi_2nodes.slurm
sbatch scripts_slurm/test_mpi_4nodes.slurm
sbatch scripts_slurm/test_mpi_6nodes.slurm
sbatch scripts_slurm/test_mpi_8nodes.slurm
```

### **Sequential Tests**
```bash
sbatch scripts_slurm/test_seq.slurm
```

## 🖥️ Running Tests with Bash Scripts

This section provides instructions for running performance tests using **Bash scripts**.

### **FastFlow Tests**
```bash
cd src/fastflow_wavefront
./test_strong_scalability_dynamic.sh
./test_strong_scalability_farm.sh
./test_strong_scalability_static.sh
./test_weak_scalability_dynamic.sh
./test_weak_scalability_farm.sh
./test_weak_scalability_static.sh
```

### **MPI Tests**
```bash
cd src/mpi_wavefront
./test_mpi.sh
./test_mpi_2nodes.sh
./test_mpi_4nodes.sh
./test_mpi_6nodes.sh
./test_mpi_8nodes.sh
```

### **Sequential Tests**
```bash
cd src/sequential_wavefront
./test_sequential.sh
```


## 📝 Repository Structure
```
.
├── 📂script_bash/                        # Bash scripts for testing
│   ├── 📄 ff_farm_wavefront.sh
│   ├── 📄 ff_wavefront.sh
│   ├── 📄 mpi_wavefront.sh
│   ├── 📄 sequential_wavefront.sh
├── 📂 script_slurm                       # SLURM scripts for running experiments
├── 📂 src/                               # Source code directory
│   ├── 📂 fastflow_wavefront/            # FastFlow-based implementation
│   │   ├── 📄 ff_farm_wavefront.cpp
│   │   ├── 📄 ff_wavefront_dynamic.cpp
│   │   ├── 📄 ff_wavefront_static.cpp
│   ├── 📂mpi_wavefront/                  # MPI-based implementation
│   │   ├── 📄 mpi_wavefront_comp.cpp
│   ├── 📂sequential_wavefront/           # Sequential version
│   │   ├── 📄 sequential_wavefront_comp.cpp
├── 📄 .gitignore
├── 📄 Makefile                           # Compilation rules
├── 📄 README.md                          # Project documentation
```