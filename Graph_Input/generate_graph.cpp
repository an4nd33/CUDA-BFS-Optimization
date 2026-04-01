#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>
using namespace std;

int main() {
    int V = 50000;   // Number of vertices
    int E = 300000;   // Number of edges

    ofstream file("graph.txt");
    file << V << " " << E << endl;

    srand(time(0));

    for (int i = 0; i < E; i++) {
        int u = rand() % V;
        int v = rand() % V;

        if (u != v)
            file << u << " " << v << endl;
        else
            i--; // avoid self-loop
    }

    file.close();

    cout << "Graph generated successfully!" << endl;
    cout << "Vertices: " << V << endl;
    cout << "Edges: " << E << endl;

    return 0;
}