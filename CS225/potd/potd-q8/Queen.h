#ifndef _QUEEN_H
#define _QUEEN_H

#include "Piece.h"
#include <string>

class Queen : public Piece {
public:
    std::string getType();
};

#endif
