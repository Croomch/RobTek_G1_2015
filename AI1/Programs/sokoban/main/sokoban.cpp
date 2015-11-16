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
                map_size_.x_ = value;
                break;
            case 1:
                map_size_.y_ = value;
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

    std::cout << "w: " << (int)map_size_.x_ << ", h: " << (int)map_size_.y_ << ", D: " << D << std::endl;

    std::cout << "Loading Map...";
    // init vectors
    diamonds_.clear();
    goals_.clear();
    map_.resize(map_size_.y_);
    for(int i = 0; i < map_size_.y_; i++){
        (map_[i]).resize(map_size_.x_);
    }

    // load map
    // X || ' ' = wall, J = diamond, G = goal, . = free space, M = robot, * = J + G
    int x = 0;
    int y = 0;
    do{
        file.get(c);

        if(c == 'X' || c == ' '){
            map_[y][x] = MAP_WALL;
        }
        else if(c == 'J'){
            map_[y][x] = MAP_FREE;
            diamonds_.emplace_back(pos_t(x,y));
        }
        else if(c == 'G'){
            map_[y][x] = MAP_GOAL;
            goals_.emplace_back(pos_t(x,y));
        }
        else if(c == '*'){
            map_[y][x] = MAP_GOAL;
            goals_.emplace_back(pos_t(x,y));
            diamonds_.emplace_back(pos_t(x,y));
        }
        else if(c == 'M'){
            map_[y][x] = MAP_FREE;
            robot_.x_ = x;
            robot_.y_ = y;
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
    printMap(map_);

    std::cout << "Init. finding paths..." << std::endl;
    // graph to store the tree of possibilities
    graph paths;
    // has a solution been found
    bool solution_found = false;

    // - make needed maps
    // heuristic map
    std::vector< std::vector<char> > heuristic_map = map_;
    wavefront(heuristic_map, goals_);
//    printMap(heuristic_map);

//    std::cout << std::endl;
    // deadlock map
    std::vector< std::vector<char> > deadlock_map = map_;
    deadlocks(deadlock_map);
//    printMap(deadlock_map);


    // the next child to consider (lowest cost)
    node * cheapest_leaf = nullptr;

    // node to add
    node nextnode(0, cheapest_leaf, heuristic_map);
    nextnode.setRobot(pos_t(robot_.x_, robot_.y_));
    nextnode.setDiamonds(diamonds_);
    std::cout << "# of Diamonds: " << diamonds_.size() << std::endl;
    // add the initial position
    paths.createChild(nextnode);

    std::cout << "Exploring paths..." << std::endl;
    // run this until the path is found or no paths can be taken
    int iterations = 0; // debug thing
    while(!solution_found && paths.getNextChild(cheapest_leaf)){
        iterations++;
        // check cheapest leaf if it is the solution
        solution_found = cheapest_leaf->compSolution(map_);
        if(!solution_found){
            // check that this node has not already been found, if so, remove it
            bool unique_node = paths.nodeUnique(*cheapest_leaf);
            bool valid_node = false;
            std::vector< pos_t > * diamonds;
            std::vector< std::vector<char> > wf_map;
            if(unique_node){
                paths.addChild(cheapest_leaf);
                // get diamonds pointer
                diamonds = cheapest_leaf->getDiamonds();
                // set diamonds to walls
                wf_map = map_;
                for(int d = 0; d < diamonds->size(); d++){
                    int x = (*diamonds)[d].x_;
                    int y = (*diamonds)[d].y_;
                    wf_map[y][x] = MAP_DIAMOND;
                }
                // check that the node is valid (all diamonds are in valid positions)
//                valid_node = true;
//                for(int i = 0; i < diamonds->size(); i++){
//                    if(!isNotCorner(diamonds->at(i), map_)){
//                        valid_node = false;
//                    }
//                }
                valid_node = validNode(diamonds, deadlock_map);

            }
            else{
                paths.deleteChild(cheapest_leaf);
            }
            if(unique_node && valid_node){
                // make wavefront from pos to see the distance to the diamonds
                std::vector< pos_t > robot_position = {*(cheapest_leaf->getRobotPos())};
                wavefront(wf_map, robot_position);
                // find the diamonds that can be moved
                std::vector< node > moves;
                possibleMoves(wf_map, diamonds, moves, cheapest_leaf);
                // add the moves to the heap (does not take care of states being the same)
                for(int newChild = 0; newChild < moves.size(); newChild++){
                    // update heuristics first
                    moves[newChild].updateHeuristic(heuristic_map);
                    // add the child
                    paths.createChild(moves[newChild]);
                }
            }
        }
        else{
            // return shortest path
            //cheapest_leaf->printPathToHere();
            cheapest_leaf->getPathToHere(path_);
        }
    }

    if(!paths.getNextChild(cheapest_leaf)){
        std::cout << "No more possible paths left to explore.\n";
    }

    std::cout << "# of iterations gone through: " << iterations << "\n";

    return solution_found;
}

void Sokoban::pathToRobot(std::string &path){
    // convert the path into Fwd, Back, Left, Right and return it in path.
    // start towards north
    char compas = 'N';
    std::string robotpath = "";
    for(int i = 0; i < path_.size(); i++){
        bool last_push = false;
        char nextMove = path_[i];
        // check if it is pushing the can
        bool pushingCan = false;
        if(!(nextMove & 0x20)){
            pushingCan = true;
        }
        // check if it is supposed to push the can further
        if(i + 1 < path_.size()){
            if(!(nextMove & 0x20) && (path_[i+1] & 0x20)){ // if current is upper and next is lowercase
                last_push = true;
            }
        } else {
            last_push = true;
        }

        // make the next move uppercase
        nextMove = nextMove & ~0x20; // always upper case
        char nextDirection;
        // check which direction to fo
        if(nextMove == compas){ // go forward if it si in the same direction
            nextDirection = 'F';
//            std::cout << compas << " and " << (char)(compas & ~0x20) << "\n";
        } else if(compas == 'N'){
            if(nextMove == 'E'){
                nextDirection = 'R';
            } else if(nextMove == 'W'){
                nextDirection = 'L';
            } else if(nextMove == 'S'){
                nextDirection = 'B';
            }

        } else if(compas == 'S'){
            if(nextMove == 'E'){
                nextDirection = 'L';
            } else if(nextMove == 'W'){
                nextDirection = 'R';
            } else if(nextMove == 'N'){
                nextDirection = 'B';
            }

        } else if(compas == 'E'){
            if(nextMove == 'N'){
                nextDirection = 'L';
            } else if(nextMove == 'S'){
                nextDirection = 'R';
            } else if(nextMove == 'W'){
                nextDirection = 'B';
            }

        } else if(compas == 'W'){
            if(nextMove == 'N'){
                nextDirection = 'R';
            } else if(nextMove == 'S'){
                nextDirection = 'L';
            } else if(nextMove == 'E'){
                nextDirection = 'B';
            }

        }
        compas = nextMove;

        // if not pushing the can, make it lower case
        if(!pushingCan){
            nextDirection = nextDirection | 0x20;
        }
        // add it to the path
        robotpath += nextDirection;
        // if last push, add a final fwd and back and turn the compas 180 degrees
        if(last_push){
            robotpath += "Fb";
            switch (compas) {
            case 'N':
                compas = 'S';
                break;
            case 'S':
                compas = 'N';
                break;
            case 'E':
                compas = 'W';
                break;
            case 'W':
                compas = 'E';
                break;
            default:
                break;
            }
        }
    }

    path = robotpath;
}


// wavefront element, used in the generation of the wavefront
struct wfElement{
    char cost_;
    pos_t point_;
    bool operator()( wfElement &a, wfElement &b)
    {
        return (a.cost_) > (b.cost_);
    }
};
// takes in a map of chars to generate a wavefront map with no-go-pos=0, and rest the cost to go there
// map consists only of free and wall elements
void Sokoban::wavefront(std::vector< std::vector<char> > &map_out, std::vector< pos_t > &state){
    // make heap
    std::vector< wfElement > wfHeap;
    std::make_heap(wfHeap.begin(), wfHeap.end(), wfElement());

    // push starting point
    wfElement current, next;
    current.cost_ = MAP_WALKABLE;
    for(int i = 0; i < state.size(); i++){
        current.point_ = state[i];
        wfHeap.push_back(current);
        std::push_heap(wfHeap.begin(), wfHeap.end(), wfElement());
    }


    // while something can be poped, do so
    while (wfHeap.size()) {
        // pop value
        current = wfHeap.front();
        std::pop_heap(wfHeap.begin(), wfHeap.end(), wfElement());
        wfHeap.pop_back();

        // set value if free
        char state = map_out[current.point_.y_][current.point_.x_];
        if(MAP_IS_EMPTY(state) || MAP_IS_GOAL(state)){
            map_out[current.point_.y_][current.point_.x_] = current.cost_;
            // add neighbours
            next.cost_ = current.cost_ + 1;
            if(current.point_.y_ > 0){
                next.point_.x_ = current.point_.x_;
                next.point_.y_ = current.point_.y_- 1;
                wfHeap.push_back(next);
                std::push_heap(wfHeap.begin(), wfHeap.end(), wfElement());
            }
            if(current.point_.y_ < map_size_.y_){
                next.point_.x_ = current.point_.x_;
                next.point_.y_ = current.point_.y_+ 1;
                wfHeap.push_back(next);
                std::push_heap(wfHeap.begin(), wfHeap.end(), wfElement());
            }
            if(current.point_.x_ > 0){
                next.point_.x_ = current.point_.x_ - 1;
                next.point_.y_ = current.point_.y_;
                wfHeap.push_back(next);
                std::push_heap(wfHeap.begin(), wfHeap.end(), wfElement());
            }
            if(current.point_.x_ < map_size_.x_){
                next.point_.x_ = current.point_.x_ + 1;
                next.point_.y_ = current.point_.y_;
                wfHeap.push_back(next);
                std::push_heap(wfHeap.begin(), wfHeap.end(), wfElement());
            }
        }
    }
}


void Sokoban::deadlocks(std::vector< std::vector<char> > &map_out){
    // go through map to mark deadlocks
    // find all corners
    std::vector< std::vector<char> > deadlocks = map_out;
    for(int i = 0; i < map_out.size(); i++){
        for(int j = 0; j < (map_out.at(i)).size(); j++){
            pos_t pos(j,i);
            if(!isNotCorner(pos,map_out)){
                deadlocks[i][j] = MAP_WALL;
            }
        }
    }
    // find the deadlocks which are next to a wall with no goal
    // that is the block can not leave the wall again
    // find wall parts that have no indnent to push the diamond out
    //
    // first look at vertical walls
    for(int j = 0; j < (map_out.at(0)).size(); j++){ // go through x (row by row)
        bool unblocked_l = false, unblocked_r = false; // assume each row is blocked
        for(int i = 0; i < map_out.size(); i++){ // go vertical down and see it there is a wall next to it that is blocking
            char element = map_out[i][j];
            // check if the wall part ends
            if(MAP_IS_WALL(element)){
                if(!(unblocked_l && unblocked_r)){ // if any of the sides were blocked, go back and mark the deadlocks
//                    std::cout << "A piece of deadlockwall was found at ";
//                    std::cout << "(" << j << ", " << i << ")\n";
                    int b = i-1;
                    while( b >= 0  && !MAP_IS_WALL(map_out[b][j])){
                        deadlocks[b][j] = MAP_WALL;
                        b--;
                    }
                }
                unblocked_l = false;
                unblocked_r = false;


            } else if(MAP_IS_GOAL(element)){ // checkif the wall path is valid - that is there is a goal at the wall
                unblocked_l = true;
                unblocked_r = true;
            }
            // check if there is a continous wall on one of the sides (set false if there is a hole in the wall)
            if(j > 0){
                if(!MAP_IS_WALL(map_out[i][j-1])){
                    unblocked_l = true;
                }
            }
            if(j < (map_out.at(i)).size() - 1 ){
                if(!MAP_IS_WALL(map_out[i][j+1])){
                    unblocked_r = true;
                }
            }
        }
    }


    // now look at horizontal walls
    for(int i = 0; i < map_out.size(); i++){ // go vertical down and see it there is a wall next to it that is blocking
        bool unblocked_l = false, unblocked_r = false; // assume each row is blocked
        for(int j = 0; j < (map_out.at(i)).size(); j++){ // go through x (row by row)
            char element = map_out[i][j];
            // check if the wall part ends
            if(MAP_IS_WALL(element)){
                if(!(unblocked_l && unblocked_r)){ // if any of the sides were blocked, go back and mark the deadlocks
//                    std::cout << "A piece of deadlockwall was found at ";
//                    std::cout << "(" << j << ", " << i << ")\n";
                    int b = j-1;
                    while( b >= 0  && !MAP_IS_WALL(map_out[i][b])){
                        deadlocks[i][b] = MAP_WALL;
                        b--;
                    }
                }
                unblocked_l = false;
                unblocked_r = false;


            } else if(MAP_IS_GOAL(element)){ // checkif the wall path is valid - that is there is a goal at the wall
                unblocked_l = true;
                unblocked_r = true;
            }
            // check if there is a continous wall on one of the sides (set false if there is a hole in the wall)
            if(i > 0){
                if(!MAP_IS_WALL(map_out[i-1][j])){
                    unblocked_l = true;
                }
            }
            if(i < map_out.size() - 1 ){
                if(!MAP_IS_WALL(map_out[i+1][j])){
                    unblocked_r = true;
                }
            }
        }
    }

    // return the image
    map_out = deadlocks;
}


// takes in a wavefronted map and the position of diamonds to output a vector of possible moves
void Sokoban::possibleMoves(std::vector< std::vector<char> > &wfmap_in, std::vector<pos_t> * &diamonds, std::vector< node > &moves, node* &origo){
    // do also find the path in terms of N S E W
    // temporary node
    node tmp;
    tmp.setParent(origo);
    // get cost ready, previous cost + the cost of pushing the diamond - the cost offset in the wavefront
    int currentCost = origo->getCost() + 1 - MAP_WALKABLE;
    pos_t robot;
    // the path
    std::string path;
    // pushing around
    pos_t pushTo;
    pos_t pushFrom = *(origo->getRobotPos());
    // reset the move vector
    moves.clear();
    // loop through the set of diamonds
    for(int d = 0; d < diamonds->size(); d++){

        // set robot pos
        robot.x_ = (*diamonds)[d].x_;
        robot.y_ = (*diamonds)[d].y_;
        tmp.setRobot(robot);
        // initiate new diamonds, can only be done because dim is modified relative to diamonds only.
        std::vector<pos_t> dim = *diamonds;
        // check for each diamond position if it can be moved up/down/left/right
        // if so, add it to the list moves
        // ensure you don't go out of border (north/south)
        if((*diamonds)[d].y_ > 0 && (*diamonds)[d].y_ < map_size_.y_){
            char north = wfmap_in[(*diamonds)[d].y_ - 1][(*diamonds)[d].x_];
            char south = wfmap_in[(*diamonds)[d].y_ + 1][(*diamonds)[d].x_];
            dim[d].x_ = (*diamonds)[d].x_;
            // check north
            if(!(MAP_IS_OCCUPIED(north)) && MAP_IS_WALKABLE(south)){
                // set values
                tmp.setCost(currentCost + south); // pushes from south
                dim[d].y_ = (*diamonds)[d].y_ - 1;
                tmp.setDiamonds(dim);
                // find path
                pushTo = robot;
                pushTo.y_ = robot.y_ + 1; // south
                if(findSubPath(path, wfmap_in, pushFrom, pushTo)){
                    path += "N";
                    tmp.setPath(path);
                }
                // add it to the vector
                moves.emplace_back(tmp);
            }
            // check south
            if(!(MAP_IS_OCCUPIED(south)) && MAP_IS_WALKABLE(north)){
                // set values
                tmp.setCost(currentCost + north); // pushes from north
                dim[d].y_ = (*diamonds)[d].y_ + 1;
                tmp.setDiamonds(dim);
                // find path
                pushTo = robot;
                pushTo.y_ = robot.y_ - 1; // north
                if(findSubPath(path, wfmap_in, pushFrom, pushTo)){
                    path += "S";
                    tmp.setPath(path);
                }
                // add it to the vector
                moves.emplace_back(tmp);
            }
        }
        // ensure you don't go out of border (west/east)
        if((*diamonds)[d].x_ > 0 && (*diamonds)[d].x_ < map_size_.x_){
            char east = wfmap_in[(*diamonds)[d].y_][(*diamonds)[d].x_ + 1];
            char west = wfmap_in[(*diamonds)[d].y_][(*diamonds)[d].x_ - 1];
            dim[d].y_ = (*diamonds)[d].y_;
            // check west
            if(!(MAP_IS_OCCUPIED(west)) && MAP_IS_WALKABLE(east)){
                // set values
                tmp.setCost(currentCost + east); // pushes from east
                dim[d].x_ = (*diamonds)[d].x_ - 1;
                tmp.setDiamonds(dim);
                // find path
                pushTo = robot;
                pushTo.x_ = robot.x_ + 1; // east
                if(findSubPath(path, wfmap_in, pushFrom, pushTo)){
                    path += "W";
                    tmp.setPath(path);
                }
                // add it to the vector
                moves.emplace_back(tmp);
            }
            // check east
            if(!(MAP_IS_OCCUPIED(east)) && MAP_IS_WALKABLE(west)){
                // set values
                tmp.setCost(currentCost + west); // pushes from west
                dim[d].x_ = (*diamonds)[d].x_ + 1;
                tmp.setDiamonds(dim);
                // find path
                pushTo = robot;
                pushTo.x_ = robot.x_ - 1; // west
                if(findSubPath(path, wfmap_in, pushFrom, pushTo)){
                    path += "E";
                    tmp.setPath(path);
                }
                // add it to the vector
                moves.emplace_back(tmp);
            }
        }
    }
}

// find the path from one position to another using a wfmap
bool Sokoban::findSubPath(std::string &path_out, std::vector< std::vector<char> > &wfmap_in, pos_t &from, pos_t &to){
    bool ret = false;
    path_out = "";
    pos_t current_pos = to;
    // start at the end (to) and follow the slope down to the start
    // this could possibly be optimized so it prefers straight paths with less turns?
    int check_cost = 0;
    int max_cost = wfmap_in[to.y_][to.x_] - wfmap_in[from.y_][from.x_];
    bool pathFound = false;
    while(!pathFound){
        // the next four options
        char north = wfmap_in[current_pos.y_ - 1][current_pos.x_];
        char south = wfmap_in[current_pos.y_ + 1][current_pos.x_];
        char east = wfmap_in[current_pos.y_][current_pos.x_ + 1];
        char west = wfmap_in[current_pos.y_][current_pos.x_ - 1];
        char here = wfmap_in[current_pos.y_][current_pos.x_];
        // find the next step
        if(north < here && MAP_IS_WALKABLE(north)){ // comes from north
            path_out = "s" + path_out; // back tracking the position
            current_pos.y_ = current_pos.y_ - 1;
        } else if(south < here && MAP_IS_WALKABLE(south)){ // comes from south
            path_out = "n" + path_out; // back tracking the position
            current_pos.y_ = current_pos.y_ + 1;
        } else if(east < here && MAP_IS_WALKABLE(east)){ // comes from east
            path_out = "w" + path_out; // back tracking the position
            current_pos.x_ = current_pos.x_ + 1;
        } else if(west < here && MAP_IS_WALKABLE(west)){ // comes from south
            path_out = "e" + path_out; // back tracking the position
            current_pos.x_ = current_pos.x_ - 1;
        }
        // increment check cost to see if the right path was found
        check_cost++;
        // returned to destination?
        if(current_pos == from){
            pathFound = true;
            ret = true;
        }
        // gone too far?
        if(check_cost > max_cost){
            pathFound = true;
        }
    }
    return ret;
}

// checks if all the diamonds are placed on valid spots
bool Sokoban::isNotCorner(pos_t &diamond, std::vector< std::vector<char> > &wallmap_in){
    bool ret = true;

    // check if the diamond is on a goal, if so, it is always valid - checks the original map for this
    if(!MAP_IS_GOAL(wallmap_in[diamond.y_][diamond.x_])){
        // check if the diamond is in a corner, use wallmap as diamonds also block
        bool north = true;
        if(diamond.y_ - 1 >= 0){
            north = MAP_IS_WALL(wallmap_in[diamond.y_ - 1][diamond.x_]);
        }
        bool south = true;
        if(diamond.y_ + 1 < wallmap_in.size()){
            south = MAP_IS_WALL(wallmap_in[diamond.y_ + 1][diamond.x_]);
        }
        bool east = true;
        if(diamond.x_ + 1 < wallmap_in[diamond.y_].size()){
            east = MAP_IS_WALL(wallmap_in[diamond.y_][diamond.x_ + 1]);
        }
        bool west = true;
        if(diamond.x_ - 1 >= 0){
            west = MAP_IS_WALL(wallmap_in[diamond.y_][diamond.x_ - 1]);
        }
        bool horizontalBlock = north | south;
        bool verticalBlock = east | west;
        if(verticalBlock && horizontalBlock){
            ret = false;
            //                std::cout << "Found a invalid node ";
            //                diamonds->at(d).print();
            //                std::cout << "\n";
        }
    }

    return ret;
}


bool Sokoban::validNode(std::vector<pos_t> * &diamonds, std::vector< std::vector<char> > &wallmap_in){
    bool ret = true;
    for(int d = 0; d < diamonds->size() && ret; d++){
        if(MAP_IS_WALL(wallmap_in[(*diamonds)[d].y_][(*diamonds)[d].x_])){
            ret = false;
        }
    }
    return ret;
}



