#include <iostream>

#include "sokoban.h"


// todo: add check so it does not push the diamonds back and forth

int main()
{
    std::cout << "Hello Sokoban Solver!" << std::endl;

    //Sokoban solver("../../../sokoban_maps/2014competition.txt");
    Sokoban solver("../../../sokoban_maps/simple_map.txt");

    //solver.printMap();

    if(solver.findPath()){
        std::cout << "Path found" << std::endl;
    }

    //solver.printMap();

    return 0;
}

