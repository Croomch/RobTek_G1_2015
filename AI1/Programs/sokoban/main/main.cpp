#include <iostream>

#include "sokoban.h"


// ****************** TODO**************

int main()
{
    std::cout << "Hello Sokoban Solver!" << std::endl;
//      Sokoban solver("../../../sokoban_maps/2015competition.txt"); //
    Sokoban solver("../../../sokoban_maps/2014competition.txt"); // 124 // cl 212228 // ol 33561
//    Sokoban solver("../../../sokoban_maps/simple_map.txt");
//    Sokoban solver("../../../sokoban_maps/Example02.txt"); // 168
//    Sokoban solver("../../../sokoban_maps/Original001.txt"); // 230
//    Sokoban solver("../../../sokoban_maps/solvertest01.txt"); // 43
//    Sokoban solver("../../../sokoban_maps/solvertest02.txt"); // 140 // #i 230545
//    Sokoban solver("../../../sokoban_maps/solvertest03.txt"); // 266 // #i 15777368
//    Sokoban solver("../../../sokoban_maps/map_spec.txt"); // 102 // #i 73201 // #cl 22760
//    Sokoban solver("../../../sokoban_maps/oopshesazipnoob/original_maps/Original001.txt"); // 230
//    Sokoban solver("../../../sokoban_maps/oopshesazipnoob/original_maps/Original090.txt"); // 102 // #i 73201 // #cl 22760
//    Sokoban solver("../../../sokoban_maps/oopshesazipnoob/microban_maps/microban006.txt"); // 107 // cl 1581 // ol 25
//    Sokoban solver("../../../sokoban_maps/oopshesazipnoob/microban_maps/microban155.txt"); //

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

