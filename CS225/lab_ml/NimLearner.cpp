/**
 * @file NimLearner.cpp
 * CS 225: Data Structures
 */

#include "NimLearner.h"
#include <ctime>

/**
 * Constructor to create a game of Nim with `startingTokens` starting tokens.
 *
 * This function creates a graph, `g_` representing all of the states of a
 * game of Nim with vertex labels "p#-X", where:
 * - # is the current player's turn; p1 for Player 1, p2 for Player2
 * - X is the tokens remaining at the start of a player's turn
 *
 * For example:
 *   "p1-4" is Player 1's turn with four (4) tokens remaining
 *   "p2-8" is Player 2's turn with eight (8) tokens remaining
 *
 * All legal moves between states are created as edges with initial weights
 * of 0.
 *
 * @param startingTokens The number of starting tokens in the game of Nim.
 */
NimLearner::NimLearner(unsigned startingTokens) : g_(true, true) {
    Vertex player1;
    Vertex player2;

    for (int remain_token = (int)startingTokens; remain_token >= 0; remain_token--) {
        player1 = "p1-" + to_string(remain_token);
        player2 = "p2-" + to_string(remain_token);
        g_.insertVertexByLabel(player1);
        g_.insertVertexByLabel(player2);
    }

    for (int i = (int)startingTokens; i >= 0; i--) {
        Vertex current_p1 = g_.getVertexByLabel("p1-" + to_string(i));
        Vertex current_p2 = g_.getVertexByLabel("p2-" + to_string(i));
        if (i + 1 <= (int)startingTokens) {
            player1 = g_.getVertexByLabel("p1-" + to_string(i + 1));
            player2 = g_.getVertexByLabel("p2-" + to_string(i + 1));
            g_.insertEdge(player2, current_p1);
            g_.insertEdge(player1, current_p2);
            g_.setEdgeWeight(player2, current_p1, 0);
            g_.setEdgeWeight(player1, current_p2, 0);
        }
        if (i + 2 <= (int)startingTokens) {
            player1 = g_.getVertexByLabel("p1-" + to_string(i + 2));
            player2 = g_.getVertexByLabel("p2-" + to_string(i + 2));
            g_.insertEdge(player2, current_p1);
            g_.insertEdge(player1, current_p2);
            g_.setEdgeWeight(player2, current_p1, 0);
            g_.setEdgeWeight(player1, current_p2, 0);
        }
    }

    startingVertex_ = g_.getVertexByLabel("p1-" + to_string(startingTokens));
    token = startingTokens;
}

/**
 * Plays a random game of Nim, returning the path through the state graph
 * as a vector of `Edge` classes.  The `origin` of the first `Edge` must be
 * the vertex with the label "p1-#", where # is the number of starting
 * tokens.  (For example, in a 10 token game, result[0].origin must be the
 * vertex "p1-10".)
 *
 * @returns A random path through the state space graph.
 */
std::vector<Edge> NimLearner::playRandomGame() const {
    vector<Edge> path;
    int remain_token = token;
    Vertex start = "p1-" + to_string(remain_token);
    int player = 2;
    while (remain_token > 0) {
        int step = rand() % 2 + 1; // In range [1, 2]
        remain_token -= step;
        if (remain_token < 0)
            remain_token = 0;
        /* Parse end string */
        Vertex end;
        if (player == 1) {
            end = "p1-" + to_string(remain_token);
            player = 2;
        } else {
            end = "p2-" + to_string(remain_token);
            player = 1;
        }
        path.push_back(g_.getEdge(start, end));
        start = end;
    }
    return path;
}

/*
 * Updates the edge weights on the graph based on a path through the state
 * tree.
 *
 * If the `path` has Player 1 winning (eg: the last vertex in the path goes
 * to Player 2 with no tokens remaining, or "p2-0", meaning that Player 1
 * took the last token), then all choices made by Player 1 (edges where
 * Player 1 is the source vertex) are rewarded by increasing the edge weight
 * by 1 and all choices made by Player 2 are punished by changing the edge
 * weight by -1.
 *
 * Likewise, if the `path` has Player 2 winning, Player 2 choices are
 * rewarded and Player 1 choices are punished.
 *
 * @param path A path through the a game of Nim to learn.
 */
void NimLearner::updateEdgeWeights(const std::vector<Edge> & path) {
    for (size_t i = 0; i < path.size(); i++) {
        if (path[path.size() - 1].dest.compare("p2-0") == 0) {
            if (path[i].source[1] == '1')
                g_.setEdgeWeight(path[i].source, path[i].dest, path[i].getWeight() + 1);
            else
                g_.setEdgeWeight(path[i].source, path[i].dest, path[i].getWeight() - 1);
        } else {
            if (path[i].source[1] == '1')
                g_.setEdgeWeight(path[i].source, path[i].dest, path[i].getWeight() - 1);
            else
                g_.setEdgeWeight(path[i].source, path[i].dest, path[i].getWeight() + 1);
        }
    }
}

/**
 * Label the edges as "WIN" or "LOSE" based on a threshold.
 */
void NimLearner::labelEdgesFromThreshold(int threshold) {
  for (const Vertex & v : g_.getVertices()) {
    for (const Vertex & w : g_.getAdjacent(v)) {
      int weight = g_.getEdgeWeight(v, w);

      // Label all edges with positve weights as "WINPATH"
      if (weight > threshold)           { g_.setEdgeLabel(v, w, "WIN"); }
      else if (weight < -1 * threshold) { g_.setEdgeLabel(v, w, "LOSE"); }
    }
  }
}

/**
 * Returns a constant reference to the state space graph.
 *
 * @returns A constant reference to the state space graph.
 */
const Graph & NimLearner::getGraph() const {
  return g_;
}
