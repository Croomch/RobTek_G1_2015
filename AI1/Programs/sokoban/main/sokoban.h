#ifndef SOKOBAN_H
#define SOKOBAN_H

#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <math.h>

#include "graph.h"


// to do: make a destructor making sure all nodes are gone
class Sokoban
{
public:
    Sokoban() {
        map_size_.y_ = 0;
        map_size_.x_ = 0;

        path_ = "";
    }

    Sokoban(std::string filename) {
        map_size_.y_ = 0;
        map_size_.x_ = 0;

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
    void pathToRobot(std::string &path);

    // return the solution path
    void getPath(std::string &path){
        path = path_;
    }


    void printMap(std::vector< std::vector<char> > &map){
        for(int y = 0; y < map.size(); y++){
            for(int x = 0; x < map[y].size(); x++){
                char e = map[y][x];
                if(e == MAP_WALL){
                    std::cout << "X";
                }
                else if(e == MAP_FREE){
                    std::cout << " ";
                }
                else if(e == MAP_GOAL){
                    std::cout << "G";
                }
                else if(e == MAP_DIAMOND){
                    std::cout << "J";
                }
                else {
                    std::cout << (int)e - MAP_WALKABLE;
                }

            }
            std::cout << std::endl;
        }
    }

private:
    // takes in a map of chars to generate a wavefront map with no-go-pos=0, and rest the cost to go there
    void wavefront(std::vector< std::vector<char> > &map_out, std::vector< pos_t > &state);
    // takes in a map of chars to generate a deadlock map with the deadlocks marked 0
    void deadlocks(std::vector< std::vector<char> > &map_out);
    // checks if all the diamonds are placed on valid spots, takes the diamonds in and a map where the diamond positions are set to walls
    bool isNotCorner(pos_t &diamonds, std::vector< std::vector<char> > &wallmap_in);
    // takes in a wavefronted map and the position of diamonds to output a vector of possible moves
    void possibleMoves(std::vector< std::vector<char> > &wfmap_in, std::vector<pos_t> * &diamonds, std::vector< node > &moves, node* &origo);
    // checks if all the diamonds are placed on valid spots, takes the diamonds in and a map where the deadlocks are set to walls
    bool validNode(std::vector<pos_t> * &diamonds, std::vector< std::vector<char> > &wallmap_in);
    // find the subpath from one node to another
    bool findSubPath(std::string &path_out, std::vector< std::vector<char> > &wfmap_in, pos_t &from, pos_t &to);


    // map of the lane (walls, empty and goals)
    // 2d vector of chars (free, goal and wall)
    pos_t map_size_;
    std::vector< std::vector<char> > map_;
    // goals (they are also on the map)
    std::vector< pos_t > goals_;
    // path, string is (N,S,E,W), case for pushes and small case for normal walks
    std::string path_;
    // dimonds init pos
    std::vector<pos_t> diamonds_;
    // robot
    pos_t robot_;

};

#endif // SOKOBAN_H
