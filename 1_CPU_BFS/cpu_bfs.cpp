#include <iostream>
#include <vector>
#include <queue>
#include <fstream>
#include <chrono>

using namespace std;
using namespace chrono;

int main() {
    ifstream file("../Graph_Input/graph.txt");

    if (!file.is_open()) {
        cout << "Error opening graph file!" << endl;
        return 1;
    }

    int V, E;
    file >> V >> E;

    vector<vector<int>> adj(V);

    int u, v;
    for (int i = 0; i < E; i++) {
        file >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    cout << "Graph loaded" << endl;
    cout << "Number of vertices: " << V << endl;
    cout << "Number of edges: " << E << endl;

    vector<bool> visited(V, false);
    queue<int> q;

    int source = 0;
    visited[source] = true;
    q.push(source);

    cout << "\nRunning CPU BFS..." << endl;

    auto start = high_resolution_clock::now();

    while (!q.empty()) {
        int node = q.front();
        q.pop();

        for (int neighbor : adj[node]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                q.push(neighbor);
            }
        }
    }

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<milliseconds>(stop - start);

    cout << "CPU BFS Time: " << duration.count() << " ms" << endl;

    return 0;
}