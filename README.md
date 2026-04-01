Parallel Breadth First Search on GPU using CUDA
1. Introduction

Breadth First Search (BFS) is a fundamental graph traversal algorithm widely used in applications such as shortest path computation, network analysis, VLSI routing, social network analysis, and web crawling.
However, BFS is computationally expensive on CPUs for large graphs due to its sequential nature and irregular memory access patterns.

This project focuses on accelerating BFS using GPU parallelization with CUDA and improving performance through several optimization techniques such as CSR representation, shared memory optimization, and load-balanced BFS.

2. Problem Statement

The objective of this project is to implement Breadth First Search on GPU and optimize it to achieve significant speedup over the CPU implementation.

Main challenges in GPU BFS:

Irregular memory access
Load imbalance (vertices have different degrees)
High number of atomic operations
Warp divergence

These challenges were addressed using GPU optimization techniques.

3. Graph Representation

The graph is stored using CSR (Compressed Sparse Row) format, which is widely used in GPU graph processing due to its memory efficiency and coalesced memory access.

CSR uses two arrays:

row_ptr[V+1] → Stores index where each vertex’s adjacency list starts
col_ind[E] → Stores adjacency list (neighbors)

Neighbors of vertex v are stored in:

col_ind[row_ptr[v] ... row_ptr[v+1] - 1]

CSR improves memory coalescing, which is critical for GPU performance.

4. Project Implementation Stages

The project was implemented in multiple stages to analyze performance improvements at each step.

Stage	Implementation	Description
Stage 1	CPU BFS	Sequential BFS used as baseline
Stage 2	GPU Naive BFS	Parallel BFS using one thread per vertex
Stage 3	GPU CSR BFS	Memory optimization using CSR
Stage 4	GPU Shared Memory BFS	Reduced global atomic operations
Stage 5	GPU Load Balanced BFS	Warp-centric BFS for load balancing
5. Optimization Techniques
5.1 Naive GPU BFS
Each GPU thread processes one vertex from the frontier.
Parallel traversal significantly reduces runtime compared to CPU.
However, performance is limited due to global memory latency and atomic operations.
5.2 CSR (Compressed Sparse Row)
Graph stored in CSR format for contiguous memory access.
Enables coalesced global memory access, improving memory throughput.
Reduced memory latency and improved GPU performance.
5.3 Shared Memory Optimization
Instead of performing atomicAdd in global memory for every thread, each block stores its local frontier in shared memory.
Only one global atomic operation per block is performed.
This significantly reduces atomic contention and improves performance.
5.4 Load Balanced BFS (Warp-Centric BFS)
In naive BFS, one thread processes one vertex.
But some vertices have many neighbors → load imbalance → warp divergence.
In load-balanced BFS, one warp (32 threads) processes one vertex, distributing neighbor processing among threads.
This improves warp efficiency and reduces divergence.
6. Performance Results

Graph Size:

Vertices: 50,000
Edges: 300,000
Implementation	Time (ms)	Speedup
CPU BFS	24	1x
GPU Naive BFS	1.03	23.3x
GPU CSR BFS	0.576	41.6x
GPU Shared Memory BFS	0.246	97.5x
GPU Load Balanced BFS	0.240	100x
7. Performance Analysis
Optimization	Performance Improvement
GPU Parallelization	Reduced sequential execution time
CSR	Improved memory coalescing
Shared Memory	Reduced global atomic operations
Load Balancing	Reduced warp divergence

The largest performance gain came from:

Shared memory optimization
Load balancing
Memory coalescing using CSR
8. Tools and Technologies Used
CUDA
NVIDIA GPU
C++
CSR Graph Representation
Shared Memory
Warp-Centric Processing
CUDA Events for Timing
Git & GitHub
9. Conclusion

This project demonstrated how GPU parallelization and memory optimization techniques can significantly accelerate graph algorithms.

The optimized GPU BFS achieved ~100× speedup compared to CPU BFS.
The project highlights the importance of:

Memory coalescing
Shared memory usage
Load balancing
Warp efficiency

These techniques are essential in high-performance computing, GPU programming, and parallel algorithm design.

10. How to Compile and Run
Compile CPU BFS
nvcc cpu_bfs.cpp -o cpu_bfs
cpu_bfs.exe
Compile GPU Naive BFS
nvcc gpu_bfs_naive.cu -o gpu_bfs
gpu_bfs.exe
Compile GPU CSR BFS
nvcc gpu_bfs_csr.cu -o gpu_bfs_csr
gpu_bfs_csr.exe
Compile GPU Shared Memory BFS
nvcc gpu_bfs_shared.cu -o gpu_bfs_shared
gpu_bfs_shared.exe
Compile GPU Load Balanced BFS
nvcc gpu_bfs_loadbalanced.cu -o gpu_bfs_loadbalanced
gpu_bfs_loadbalanced.exe
11. Repository Structure
CUDA_BFS_Project/
│
├── 1_CPU_BFS/
├── 2_GPU_BFS_Naive/
├── 3_GPU_BFS_CSR/
├── 4_GPU_BFS_Shared/
├── 5_GPU_BFS_LoadBalanced/
│
├── Graph_Input/
├── Screenshots/
├── Results/
└── README.md
12. Future Work
Direction-Optimizing BFS
Multi-GPU BFS
Graph partitioning
Using CUDA streams for overlap
Using Unified Memory
BFS for weighted graphs (SSSP)
