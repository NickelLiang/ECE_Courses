#include <iostream>
#include "dsets.h"
#include "maze.h"
#include "cs225/PNG.h"

using namespace std;

int main() {
    SquareMaze maze;
    maze.makeMaze(50, 25);
    PNG * output = maze.drawMazeSemiCircle();
    output->writeToFile("creative"+ string(".png"));
}
