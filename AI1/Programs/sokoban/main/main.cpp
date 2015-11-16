#include <iostream>

#include "sokoban.h"


int main()
{
    std::cout << "Hello Sokoban Solver!" << std::endl;

    Sokoban solver("../../../sokoban_maps/2014competition.txt"); // 124
//    Sokoban solver("../../../sokoban_maps/simple_map.txt");
//    Sokoban solver("../../../sokoban_maps/Example02.txt"); // 168
//    Sokoban solver("../../../sokoban_maps/Original001.txt"); // 230
//    Sokoban solver("../../../sokoban_maps/solvertest01.txt"); // 43
//    Sokoban solver("../../../sokoban_maps/solvertest02.txt"); // 140 // # of iterations gone through: 230545
//    Sokoban solver("../../../sokoban_maps/solvertest03.txt"); // 266 // # of iterations gone through: 85202641

    if(solver.findPath()){
        std::cout << "Path found!" << std::endl;
        std::string path;
        solver.getPath(path);
        std::cout << "The path to the solution is: " << path << std::endl;
        std::cout << "The path length is: " << path.size() << std::endl;

        std::string finalPath;
        solver.pathToRobot(finalPath);
        std::cout << "the final path is: " << finalPath << "\n";

    }

    return 0;
}

