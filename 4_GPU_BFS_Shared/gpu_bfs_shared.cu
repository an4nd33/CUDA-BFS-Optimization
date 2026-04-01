#include <iostream>
#include <vector>
#include <fstream>
#include <cuda_runtime.h>

using namespace std;

__global__ void bfs_shared(int *row_ptr, int *col_ind, int *frontier,
                           int *next_frontier, int *visited,
                           int *global_next_size, int V) {

    __shared__ int local_frontier[1024];
    __shared__ int local_count;

    if (threadIdx.x == 0)
        local_count = 0;

    __syncthreads();

    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < V && frontier[idx] != -1) {
        int node = frontier[idx];
        frontier[idx] = -1;

        for (int i = row_ptr[node]; i < row_ptr[node + 1]; i++) {
            int neighbor = col_ind[i];

            if (visited[neighbor] == 0) {
                visited[neighbor] = 1;
                int pos = atomicAdd(&local_count, 1);
                local_frontier[pos] = neighbor;
            }
        }
    }

    __syncthreads();

    if (threadIdx.x == 0) {
        int pos = atomicAdd(global_next_size, local_count);
        for (int i = 0; i < local_count; i++) {
            next_frontier[pos + i] = local_frontier[i];
        }
    }
}

int main() {
    ifstream file("../Graph_Input/graph.txt");

    int V, E;
    file >> V >> E;

    vector<vector<int>> adj(V);
    int u, v;

    for (int i = 0; i < E; i++) {
        file >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    vector<int> row_ptr(V + 1);
    vector<int> col_ind;

    int edge_count = 0;
    for (int i = 0; i < V; i++) {
        row_ptr[i] = edge_count;
        for (int j : adj[i]) {
            col_ind.push_back(j);
            edge_count++;
        }
    }
    row_ptr[V] = edge_count;

    int *d_row_ptr, *d_col_ind, *d_frontier, *d_next_frontier;
    int *d_visited, *d_next_size;

    cudaMalloc(&d_row_ptr, (V + 1) * sizeof(int));
    cudaMalloc(&d_col_ind, edge_count * sizeof(int));
    cudaMalloc(&d_frontier, V * sizeof(int));
    cudaMalloc(&d_next_frontier, V * sizeof(int));
    cudaMalloc(&d_visited, V * sizeof(int));
    cudaMalloc(&d_next_size, sizeof(int));

    cudaMemcpy(d_row_ptr, row_ptr.data(), (V + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_ind, col_ind.data(), edge_count * sizeof(int), cudaMemcpyHostToDevice);

    vector<int> frontier(V, -1);
    frontier[0] = 0;

    cudaMemcpy(d_frontier, frontier.data(), V * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemset(d_visited, 0, V * sizeof(int));
    cudaMemset(d_next_size, 0, sizeof(int));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    bfs_shared<<<(V/256)+1, 256>>>(d_row_ptr, d_col_ind, d_frontier,
                                   d_next_frontier, d_visited,
                                   d_next_size, V);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cout << "GPU Shared Memory BFS Time: " << milliseconds << " ms" << endl;

    return 0;
}