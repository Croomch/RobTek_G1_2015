#include "sokoban.h"


bool Sokoban::loadMap(std::string filename){
    int D = 0;
    // make pointer to file
    std::cout << "Loading file... ";
    std::ifstream file(filename);

    if(!file.is_open()){
        std::cout << "Couldn't open the file" << std::endl;
        return false;
    }

    std::cout << "Done." << std::endl;

    // read file letter by letter
    char c;

    // load file dimensions and diamonds
    char entry = 0;
    int value = 0;
    std::cout << "Loading map settings... ";

    do{
        file.get(c);
        if(c >= '0' && c <= '9'){
            value = value * 10 + (c - '0');
        }
        else{
            switch (entry) {
            case 0:
                map_size_.x = value;
                break;
            case 1:
                map_size_.y = value;
                break;
            case 2:
                D = value;
                break;
            default:
                break;
            }

            entry++;
            value = 0;
        }
    }while (!(c == '\0' || c == '\n'));
    std::cout << "Done." << std::endl;

    std::cout << "w: " << (int)map_size_.x << ", h: " << (int)map_size_.y << ", D: " << D << std::endl;

    std::cout << "Loading Map...";
    // init vectors
    diamonds_.resize(D);
    map_.resize(map_size_.y);
    for(int i = 0; i < map_size_.y; i++){
        (map_[i]).resize(map_size_.x);
    }

    // load map
    // X || ' ' = wall, J = diamond, G = goal, . = free space, M = robot, * = J + G
    int x = 0;
    int y = 0;
    int d = 0;
    do{
        file.get(c);

        if(c == 'X' || c == ' '){
            map_[y][x] = MAP_WALL;
        }
        else if(c == 'J'){
            map_[y][x] = MAP_FREE;
            diamonds_[d].x = x;
            diamonds_[d].y = y;
            d++;
        }
        else if(c == 'G'){
            map_[y][x] = MAP_GOAl;
        }
        else if(c == '*'){
            map_[y][x] = MAP_GOAl;
            diamonds_[d].x = x;
            diamonds_[d].y = y;
            d++;
        }
        else if(c == 'M'){
            map_[y][x] = MAP_FREE;
            robot_.x = x;
            robot_.y = y;
        }
        else if(c == '.'){
            map_[y][x] = MAP_FREE;
        }
        else {
            y++;
            x = -1;
        }
        x++;

    }while (!file.eof());

    std::cout << "Done." << std::endl;

    // close stream
    file.close();

    // return true
    return true;
}


// graph where s_i = {pos_D, pos_R, cost}, pointer to parents.
// possible entries (diamond pushes) are added with wavefront
// the shortest path till now is explored further (heap)
// hash table to check if node exists
bool Sokoban::findPath(){
    std::cout << "Init. finding paths..." << std::endl;
    // graph to store the tree of possibilities
    graph paths;
    // has a solution been found
    bool solution_found = false;
    // make raw map
    std::vector< std::vector<char> > wall_map;


    // the next child to consider (lowest cost)
    node * cheapest_leaf = nullptr;


    int test = 12;
    // add the initial position
    paths.addChild(test);

    std::cout << "Exploring paths..." << std::endl;
    // run this until the path is found or no paths can be taken
    while(!solution_found && paths.getNextChild(cheapest_leaf)){
        // check cheapest leaf if it is the solution
        int goals_found = 0;//cheapest_leaf->compSolution(diamonds_);
        if(goals_found == diamonds_.size()){
            solution_found = true;
            std::cout << "Solution found!" << std::endl;
            break;
        }


        // make wavefront from pos to see which diamonds can be moved and the cost
        std::cout << "Starting wavefront..." << std::endl;
        std::vector< std::vector<char> > wf_map;// = wall_map;
        wavefront(wf_map, (cheapest_leaf->getDiamonds()), (cheapest_leaf->getRobotPos()));
        // if it is a valid move and has not occured previously, add it to the heap
        //paths.addChild(test,cheapest_leaf);

    }



    // repeat until the shortest solution is found

    // return shortest path

    return solution_found;
}

void Sokoban::pathToRobot(){

}


// takes in a map of chars to generate a wavefront map with no-go-pos=0, and rest the cost to go there
// map consists only of free and wall elements
void Sokoban::wavefront(std::vector< std::vector<char> > &map_out, std::vector<pos_t> *diamonds, pos_t *robot_pos){
    std::cout << "Runing wavefront..." << std::endl;
    robot_pos->print();

}



// takes in a wavefronted map and the position of diamonds to output a vector of possible moves
void Sokoban::possibleMoves(std::vector< std::vector<char> > &wfmap_in, std::vector<pos_t> &diamonds, std::vector< node > &moves){

}



