#include <string>


#define MAP_FREE 0
#define MAP_WALL 1
#define MAP_GOAl 2


class Sokoban
{
public:
    Sokoban() {}

    bool loadMap(std::string filename);

    // graph where s_i = {pos_D, pos_R, cost}, pointer to parents.
    // possible entries (diamond pushes) are added with wavefront
    // the shortest path till now is explored further
    // hash table to check if node exists
    bool findPath();

    // converts NSEW to BFLR
    void pathToRobot();

private:
    // map of the lane (walls, empty and goals)
        // map= 2d vector of chars (free, goal and wall)
    // path
        // string (N,S,E,W)
    // dimonds init pos
        // vector of (int x,y)
    // robot
        // int (x,y)

};
