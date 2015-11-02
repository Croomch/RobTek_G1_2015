#include <iostream>

#include "sokoban.h"


int main()
{
    std::cout << "Hello Sokoban Solver!" << std::endl;

    Sokoban solver("../../../sokoban_maps/2014competition.txt");
    //Sokoban solver("../../../sokoban_maps/simple_map.txt");

    if(solver.findPath()){
        std::cout << "Path found!" << std::endl;
        std::string path;
        solver.getPath(path);
        std::cout << "The path to the solution is: " << path << std::endl;
    }

    return 0;
}

