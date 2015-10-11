#ifndef SOKOBAN_H
#define SOKOBAN_H

#include <string>
#include <iostream>
#include <vector>
#include <fstream>

#include "graph.h"

#define MAP_FREE 0
#define MAP_WALL 1
#define MAP_GOAl 2



class Sokoban
{
public:
    Sokoban() {
        map_size_.y = 0;
        map_size_.x = 0;

        path_ = "";
    }

    Sokoban(std::string filename) {
        map_size_.y = 0;
        map_size_.x = 0;

        path_ = "";

        if(loadMap(filename)){
            std::cout << "File successfully loaded." << std::endl;
        }
        else {
            std::cout << "File couldn't be loaded." << std::endl;
        }
    }

    ~Sokoban() {}

    bool loadMap(std::string filename);

    // graph where s_i = {pos_D, pos_R, cost}, pointer to parents.
    // possible entries (diamond pushes) are added with wavefront
    // the shortest path till now is explored further
    // hash table to check if node exists
    bool findPath();

    // converts NSEW to BFLR
    void pathToRobot();

    void printMap(){
        for(int y = 0; y < map_size_.y; y++){
            for(int x = 0; x < map_size_.x; x++){
                char e = map_[y][x];
                if(e == MAP_WALL){
                    std::cout << "X";
                }
                else if(e == MAP_FREE){
                    std::cout << " ";
                }
                else if(e == MAP_GOAl){
                    std::cout << "G";
                }

            }
            std::cout << std::endl;
        }
    }

private:
    // takes in a map of chars to generate a wavefront map with no-go-pos=0, and rest the cost to go there
    void wavefront(std::vector< std::vector<char> > &map_out, std::vector<pos_t> * diamonds, pos_t * robot_pos);
    // takes in a wavefronted map and the position of diamonds to output a vector of possible moves
    void possibleMoves(std::vector< std::vector<char> > &wfmap_in, std::vector<pos_t> &diamonds, std::vector< node > &moves);

    // map of the lane (walls, empty and goals)
    // 2d vector of chars (free, goal and wall)
    pos_t map_size_;
    std::vector< std::vector<char> > map_;
    // path
    // string (N,S,E,W)
    std::string path_;
    // dimonds init pos
    std::vector<pos_t> diamonds_;
    // robot
    pos_t robot_;

};

#endif // SOKOBAN_H
