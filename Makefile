# Compiler and Flags
CXX = g++
MPICXX = mpic++
CXXFLAGS = -O3 -std=c++20 -Isrc
MPIFLAGS = -O3 -march=native -ffast-math -fopenmp

# Targets
all: sequential fastflow mpi

# Sequential
src/sequential_wavefront/sequential_wavefront_comp.exe: src/sequential_wavefront/sequential_wavefront_comp.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# Fastflow
src/fastflow_wavefront/ff_farm_wavefront.exe: src/fastflow_wavefront/ff_farm_wavefront.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

src/fastflow_wavefront/ff_wavefront_static.exe: src/fastflow_wavefront/ff_wavefront_static.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

src/fastflow_wavefront/ff_wavefront_dynamic.exe: src/fastflow_wavefront/ff_wavefront_dynamic.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# MPI
src/mpi_wavefront/mpi_wavefront.exe: src/mpi_wavefront/mpi_wavefront_comp.cpp
	$(MPICXX) $(MPIFLAGS) -o $@ $<

# Rules
sequential: src/sequential_wavefront/sequential_wavefront_comp.exe
fastflow: src/fastflow_wavefront/ff_farm_wavefront.exe src/fastflow_wavefront/ff_wavefront_static.exe src/fastflow_wavefront/ff_wavefront_dynamic.exe
mpi: src/mpi_wavefront/mpi_wavefront.exe

# Clean
clean:
	rm -f src/sequential_wavefront/sequential_wavefront_comp.exe
	rm -f src/fastflow_wavefront/ff_farm_wavefront.exe
	rm -f src/fastflow_wavefront/ff_wavefront_static.exe
	rm -f src/fastflow_wavefront/ff_wavefront_dynamic.exe
	rm -f src/mpi_wavefront/mpi_wavefront.exe
