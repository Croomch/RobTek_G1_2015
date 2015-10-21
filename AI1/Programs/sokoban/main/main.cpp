#include <iostream>

#include "sokoban.h"


// todo: find error for why it stops early, probably it does not find possible paths to add?..

int main()
{
    std::cout << "Hello Sokoban Solver!" << std::endl;

    Sokoban solver("../../../sokoban_maps/2014competition.txt");
    //Sokoban solver("../../../sokoban_maps/simple_map.txt");

    //solver.printMap();

    if(solver.findPath()){
        std::cout << "Path found" << std::endl;
    }

    solver.printMap();

    return 0;
}

