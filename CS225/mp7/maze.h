/* Your code here! */
#ifndef MAZE_H
#define MAZE_H

#include "dsets.h"
#include "cs225/PNG.h"
#include <vector>

using namespace std;
using namespace cs225;

class SquareMaze {
public:
    SquareMaze();
    void makeMaze(int width, int height);
    bool canTravel(int x, int y, int dir) const;
    void setWall(int x, int y, int dir, bool exists);
    vector<int> solveMaze();
    PNG *drawMaze();
    PNG *drawMazeSemiCircle();
    PNG *drawMazeWithSolution();
    void DFSbacktracing(vector<int>* temp, vector<int>* visited, vector<int>* position, int x, int y);
private:
    int width_, height_;
    vector<bool> rightWall_;
    vector<bool> downWall_;
    DisjointSets sets_;
    int exit_;
};

#endif
