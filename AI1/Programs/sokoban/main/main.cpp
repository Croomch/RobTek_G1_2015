#include <iostream>

#include "sokoban.h"


int main()
{
    std::cout << "Hello Sdfdokoban Solver!" << std::endl;

    //Sokoban solver("../../../sokoban_maps/2014competition.txt");
    Sokoban solver("../../../sokoban_maps/simple_map.txt");

    //solver.printMap();

    solver.findPath();

    return 0;
}

