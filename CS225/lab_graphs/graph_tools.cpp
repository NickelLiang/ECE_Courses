/**
 * @file graph_tools.cpp
 * This is where you will implement several functions that operate on graphs.
 * Be sure to thoroughly read the comments above each function, as they give
 *  hints and instructions on how to solve the problems.
 */

#include "graph_tools.h"

Edge GraphTools::BFS_(Graph& graph, Vertex start) {
    queue<Edge> frontier;
    vector<Vertex> genesis = graph.getAdjacent(start);
    for(size_t i = 0; i < genesis.size(); ++i){
        frontier.push(graph.getEdge(start, genesis[i]));
    }
    graph.setVertexLabel(start, "VISITED");
    Edge smallest = frontier.front();
    while(!(frontier.empty())){
        Edge cur_edge = frontier.front();
        frontier.pop();
        if(graph.getEdgeLabel(cur_edge.source, cur_edge.dest) == "VISITED")
            continue; // this edge has already been expanded
        graph.setEdgeLabel(cur_edge.source, cur_edge.dest, "VISITED");
        if(cur_edge < smallest){
            smallest = cur_edge;
        }
        if(graph.getVertexLabel(cur_edge.dest) == "VISITED")
            continue; // already expanded from that node
        graph.setVertexLabel(cur_edge.dest, "VISITED");
        vector<Vertex> new_inter = graph.getAdjacent(cur_edge.dest);
        for(size_t i = 0; i < new_inter.size(); ++i){
            frontier.push(graph.getEdge(cur_edge.dest, new_inter[i]));
        }
    }
    return smallest;
}

/**
 * Finds the minimum edge weight in the Graph graph.
 * THIS FUNCTION IS GRADED.
 *
 * @param graph - the graph to search
 * @return the minimum weighted edge
 *
 * @todo Label the minimum edge as "MIN". It will appear blue when
 *  graph.savePNG() is called in minweight_test.
 *
 * @note You must do a traversal.
 * @note You may use the STL stack and queue.
 * @note You may assume the graph is connected.
 *
 * @hint Initially label vertices and edges as unvisited.
 */
int GraphTools::findMinWeight(Graph& graph) {
    vector<Vertex> vertices = graph.getVertices();
    vector<Edge> edges = graph.getEdges();
    for(size_t i = 0; i < vertices.size(); i++){
      graph.setVertexLabel(vertices[i], "UNVISITED");
    }
    for(size_t j = 0; j < edges.size(); j++){
      graph.setEdgeLabel(edges[j].source, edges[j].dest, "UNVISITED");
    }
    Vertex start_point = graph.getStartingVertex();
    Edge minimal_edge = GraphTools::BFS_(graph, start_point);
    graph.setEdgeLabel(minimal_edge.source, minimal_edge.dest, "MIN");
    return minimal_edge.getWeight();
}

/**
 * Returns the shortest distance (in edges) between the Vertices
 *  start and end.
 * THIS FUNCTION IS GRADED.
 *
 * @param graph - the graph to search
 * @param start - the vertex to start the search from
 * @param end - the vertex to find a path to
 * @return the minimum number of edges between start and end
 *
 * @todo Label each edge "MINPATH" if it is part of the minimum path
 *
 * @note Remember this is the shortest path in terms of edges,
 *  not edge weights.
 * @note Again, you may use the STL stack and queue.
 * @note You may also use the STL's unordered_map, but it is possible
 *  to solve this problem without it.
 *
 * @hint In order to draw (and correctly count) the edges between two
 *  vertices, you'll have to remember each vertex's parent somehow.
 */
int GraphTools::findShortestPath(Graph& graph, Vertex start, Vertex end) {
    vector<Vertex> vertices = graph.getVertices();
    for(size_t i = 0; i < vertices.size(); i++){
        graph.setVertexLabel(vertices[i], "UNVISITED");
    }
    vector<Edge> edges = graph.getEdges();
    for(size_t j = 0; j < edges.size(); j++){
        graph.setEdgeLabel(edges[j].source, edges[j].dest, "UNVISITED");
    }

    queue<Vertex> frontier;
    frontier.push(start);
    graph.setVertexLabel(start, "VISITED");

    std::map<Vertex, Vertex> route_visited;

    while(!(frontier.empty())){
        Vertex cur_vertex = frontier.front();
        frontier.pop();
        vector<Vertex> adjacent = graph.getAdjacent(cur_vertex);

        for(size_t i = 0; i < adjacent.size(); i++){
            Vertex temp = adjacent[i];
            if(graph.getVertexLabel(temp) == "UNVISITED"){
                graph.setEdgeLabel(cur_vertex, temp, "VISITED");
                graph.setVertexLabel(temp, "VISITED");
                frontier.push(temp);
                route_visited.insert({temp, cur_vertex});
            }
        }
    }
    int iter = 0;
    while(start != end){
        graph.setEdgeLabel(route_visited[end], end, "MINPATH");
        end = route_visited[end];
        ++iter;
    }
    return iter;
}

/**
 * Finds a minimal spanning tree on a graph.
 * THIS FUNCTION IS GRADED.
 *
 * @param graph - the graph to find the MST of
 *
 * @todo Label the edges of a minimal spanning tree as "MST"
 *  in the graph. They will appear blue when graph.savePNG() is called.
 *
 * @note Use your disjoint sets class from MP 7.1 to help you with
 *  Kruskal's algorithm. Copy the files into the dsets.h and dsets.cpp .
 * @note You may call std::sort instead of creating a priority queue.
 */
void GraphTools::findMST(Graph& graph) {
    graph.savePNG("debug");
    vector<Vertex> vertices = graph.getVertices();
    map<Vertex, int> index_map;
    for(size_t i = 0; i < vertices.size(); ++i){
        index_map[vertices[i]] = (int)i;
    }
    vector<Edge> edges = graph.getEdges();
    std::sort(edges.begin(), edges.end());
    DisjointSets my_dset;
    my_dset.addelements((int)vertices.size());
    size_t mst_edge_count = 0;
    for(size_t i = 0; i < edges.size(); ++i){
        if(mst_edge_count == vertices.size() - 1)
            return;
        int src_v = index_map[edges[i].source];
        int des_v = index_map[edges[i].dest];
        if(my_dset.find(src_v) != my_dset.find(des_v)){
            my_dset.setunion(src_v, des_v);
            graph.setEdgeLabel(vertices[src_v], vertices[des_v], "MST");
        }
    }
}
