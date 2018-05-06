/* Your code here! */
#include "maze.h"
#include <iostream>
#include <vector>
#include <cstdlib>
#include <cmath>

using namespace std;

SquareMaze::SquareMaze() {}

void SquareMaze::makeMaze(int width, int height) {
    width_ = width;
    height_ = height;
    rightWall_.resize(width * height, true);
    downWall_.resize(width * height, true);
    sets_.addelements(width * height);
    srand(time(NULL));
    for (int i = 0; i < width * height; i ++) {
        int x = i % width;
        int y = i / width;
        vector<int> random;
        random.push_back(0);
        random.push_back(1);
        random_shuffle(random.begin(),random.end());
        int dir = random[abs(rand() % 2)];
        if (dir == 0) {
            int next = y * width + x + 1;
            if (next < width * height && (x + 1) < width && sets_.find(i) != sets_.find(next)) {
                setWall(x, y, dir, false);
                sets_.setunion(sets_.find(i), sets_.find(next));
            }
        }
        else {
            int next = (y + 1) * width + x;
            if (next < width * height && (y + 1) < height && sets_.find(i) != sets_.find(next)) {
                setWall(x, y, dir, false);
                sets_.setunion(sets_.find(i), sets_.find(next));
            }
        }
    }
    for (int j = 0; j < width * height; j ++) {
        int x = j % width;
        int y = j / width;
        int right = y * width + x + 1;
        int down = (y + 1) * width + x;
        if (right < width * height && (x + 1) < width && sets_.find(j) != sets_.find(right)) {
            setWall(x, y, 0, false);
            sets_.setunion(sets_.find(j), sets_.find(right));
        }
        if(down < width * height && (y + 1) < height && sets_.find(j) != sets_.find(down)) {
            setWall(x, y, 1, false);
            sets_.setunion(sets_.find(j), sets_.find(down));
        }
    }
}

bool SquareMaze::canTravel(int x, int y, int dir) const {
    if (dir == 0 && x < (width_ - 1))
        return (!rightWall_[y * width_ + x]);
    if (dir == 1 && y < (height_ - 1))
        return (!downWall_[y * width_ + x]);
    if (dir == 2 && x > 0)
        return (!rightWall_[y * width_ + x - 1]);
    if (dir == 3 && y > 0)
        return (!downWall_[(y - 1) * width_ + x]);
    return false;
}

void SquareMaze::setWall(int x, int y, int dir, bool exists) {
    if (dir == 0 && x < (width_ - 1))
        rightWall_[y * width_ + x] = exists;
    if (dir == 1 && y < (height_ - 1))
        downWall_[y * width_ + x] = exists;
}

vector<int> SquareMaze::solveMaze() {
    vector<int> position;
    vector<int> path;
    vector<int> temp;
    vector<int> visited;
    visited.resize(width_ * height_, 0);
    DFSbacktracing(&temp, &visited, &position, 0, 0);
    for (size_t i = 0; i < position.size() - 1; i ++) {
        if (position[i] / width_ < position[i + 1] / width_) {
            path.push_back(1);
            continue;
        }
        if (position[i] / width_ > position[i + 1] / width_) {
            path.push_back(3);
            continue;
        }
        if (position[i] % width_ < position[i + 1] % width_) {
            path.push_back(0);
            continue;
        }
        if (position[i] % width_ > position[i + 1] % width_) {
            path.push_back(2);
            continue;
        }
    }
    return path;
}

PNG *SquareMaze::drawMaze() {
    PNG *png = new PNG(width_ * 10 + 1, height_ * 10 + 1);
    for (int i = 10; i < width_ * 10; i ++) {
        HSLAPixel *pixel = &(png->getPixel(i, 0));
        pixel->l = 0;
    }
    for (int i = 0; i < height_ * 10; i ++) {
        HSLAPixel *pixel = &(png->getPixel(0, i));
        pixel->l = 0;
    }
    for (int i = 0; i < width_ * height_; i ++) {
        int x = i % width_;
        int y = i / width_;
        if (rightWall_[i] == true) {
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel((x + 1) * 10, y * 10 + j));
                pixel->l = 0;
            }
        }
        if (downWall_[i] == true) {
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel(x * 10 + j, (y + 1) * 10));
                pixel->l = 0;
            }
        }
    }
    return png;
}

PNG *SquareMaze::drawMazeSemiCircle() {
    PNG *png = new PNG(width_ * 10 + 100, height_ * 10 + 100);
    int origin_x = width_ * 5;
    int origin_y = 0;
    int radius = width_ * 5;

    // Draw the maze
    for (int i = 0; i < width_ * height_; i++) {
        int x = i % width_;
        int y = i / width_;
        if (((origin_x - x * 10) * (origin_x - x * 10) + (origin_y - y * 10) * (origin_y - y * 10) < radius * radius) && (y >= origin_y)) {
            if (rightWall_[i] == true) {
                for (int j = 0; j <= 10; j++) {
                    HSLAPixel *pixel = &(png->getPixel((x + 6) * 10, (y + 5) * 10 + j));
                    pixel->l = 0;
                }
            }
            if (downWall_[i] == true) {
                for (int j = 0; j <= 10; j++) {
                    HSLAPixel *pixel = &(png->getPixel((x + 5) * 10 + j, (y + 6) * 10));
                    pixel->l = 0;
                }
            }
        }
    }

    // Draw outline
    for (int x = 50; x < width_ * 10 + 60; x++) {
        for (int y = 50; y < height_ * 10 + 60; y++) {
            if ((origin_x - x + 55) * (origin_x - x + 55) + (origin_y - y + 55) * (origin_y - y + 55) - radius * radius < 400 && \
                (origin_x - x + 55) * (origin_x - x + 55) + (origin_y - y + 55) * (origin_y - y + 55) - radius * radius > -400) {
                HSLAPixel *pixel = &(png->getPixel(x, y));
                pixel->l = 0;
            }
            if (origin_y - y > -52 && origin_y - y < 52) {
                HSLAPixel *pixel = &(png->getPixel(x, y));
                pixel->l = 0;
            }
        }
    }

    // Erase extra stuff
    for (int x = 50; x < width_ * 10 + 60; x++) {
        for (int y = 50; y < height_ * 10 + 60; y++) {
            if ((origin_x - x + 55) * (origin_x - x + 55) + (origin_y - y + 55) * (origin_y - y + 55) - radius * radius > 400) {
                HSLAPixel *pixel = &(png->getPixel(x, y));
                pixel->l = 1;
            }
        }
    }

    return png;
}

PNG *SquareMaze::drawMazeWithSolution() {
    PNG *png = drawMaze();
    vector<int> path = solveMaze();
    int x = 5;
    int y = 5;
    for (size_t i = 0; i < path.size(); i ++) {
        switch(path[i]) {
            case 0:
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel(x + j, y));
                pixel->h = 0;
                pixel->s = 1;
                pixel->l = 0.5;
            }
            x += 10;
            break;
            case 1:
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel(x, y + j));
                pixel->h = 0;
                pixel->s = 1;
                pixel->l = 0.5;
            }
            y += 10;
            break;
            case 2:
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel(x - j, y));
                pixel->h = 0;
                pixel->s = 1;
                pixel->l = 0.5;
            }
            x -= 10;
            break;
            case 3:
            for (int j = 0; j <= 10; j ++) {
                HSLAPixel *pixel = &(png->getPixel(x, y - j));
                pixel->h = 0;
                pixel->s = 1;
                pixel->l = 0.5;
            }
            y -= 10;
            break;
        }
    }
    y += 5;
    x -= 5;
    for(int j = 1; j < 10; j ++) {
        HSLAPixel* pixel = &(png->getPixel(x + j, y));
        pixel->l = 1;
    }
    return png;
}

void SquareMaze::DFSbacktracing(vector<int>* temp, vector<int>* visited, vector<int>* position, int x, int y) {
    temp->push_back(y * width_ + x);
    (*visited)[y * width_ + x] = 1;
    if (y == height_ - 1) {
        if(temp->size() > position->size()) {
            *position = *temp;
            exit_ = x;
        }
        if(temp->size() == position->size() && exit_ > x) {
            *position = *temp;
            exit_ = x;
        }
    }
    if (canTravel(x, y, 0) && (*visited)[y * width_ + x + 1] == 0) {
        DFSbacktracing(temp, visited, position, x + 1, y);
    }
    if (canTravel(x, y, 1) && (*visited)[(y + 1) * width_ + x] == 0) {
        DFSbacktracing(temp, visited, position, x, y + 1);
    }
    if (canTravel(x, y, 2) && (*visited)[y * width_ + x - 1] == 0) {
        DFSbacktracing(temp, visited, position, x - 1, y);
    }
    if (canTravel(x, y, 3) && (*visited)[(y - 1) * width_ + x] == 0) {
        DFSbacktracing(temp, visited, position, x, y - 1);
    }
    if (!temp->empty()) temp->pop_back();
    return;
}
