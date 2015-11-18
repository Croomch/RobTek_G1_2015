#ifndef GRAPH_H
#define GRAPH_H

#include <algorithm>
#include <vector>
#include <iostream>
#include <unordered_map>

#define MAP_FREE 0
#define MAP_WALL 1
#define MAP_GOAL 2
#define MAP_DIAMOND 3
#define MAP_WALKABLE 4
#define MAP_IS_WALKABLE(x) (x>=MAP_WALKABLE)?true:false
#define MAP_IS_GOAL(x) (x==MAP_GOAL)?true:false
#define MAP_IS_WALL(x) (x==MAP_WALL)?true:false
#define MAP_IS_EMPTY(x) (x==MAP_FREE)?true:false
#define MAP_IS_OCCUPIED(x) (x==MAP_WALL || x==MAP_DIAMOND)?true:false

struct pos_t{
    char x_, y_;
    pos_t():x_(0),y_(0){}
    pos_t(char x, char y):x_(x),y_(y){}

    bool operator== (const pos_t &other){
        bool ret = false;
        if(x_ == other.x_ && y_ == other.y_){
            ret = true;
        }
        return ret;
    }

    bool operator< (const pos_t &other)const{
        bool ret = false;
        if(x_ < other.x_){
            ret = true;
        }
        else if(x_ == other.x_){
            if(y_ < other.y_){
                ret = true;
            }
        }
        return ret;
    }

    bool operator() (const pos_t &a, const pos_t &b)const {
        return a < b;
    }

    void print(){
        std::cout << "{" << (int)x_ << ", " << (int)y_ << "}";
    }
};





class node
{
public:
    node():parent_(nullptr),cost_(0),heuristic_(0),path_(""){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int cost):cost_(cost),parent_(nullptr),heuristic_(0),path_(""){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int cost, node * &parent):cost_(cost),parent_(parent),heuristic_(0),path_(""){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int element, node * &parent, std::vector< std::vector<char> > &heuristicmap):cost_(element),parent_(parent),path_(""){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
        updateHeuristic(heuristicmap);
    }
    node(const node &init){
        *this = init;
        makeKey();
    }

    std::string getPath(){return path_;}
    int getCost(){return cost_;}

    int getHeuristic(){return heuristic_;}

    std::string * getKey(){ return &key_;}

    void setCost(int cost){
      cost_ = cost;
    }

    void setPath(std::string &path){
      path_ = path;
    }

    void setRobot(pos_t pos){
        robot_pos_ = pos;
        makeKey();
    }

    void setParent(node * &parent){
      parent_ = parent;
    }

    void setDiamonds(std::vector< pos_t > &diamonds){
        diamonds_ = diamonds;
        makeKey();
    }

    node* getParent(){return parent_;}

    std::vector< pos_t > * getDiamonds(){return &diamonds_;}

    pos_t * getRobotPos(){return &robot_pos_;}

    void getPathToHere(std::string &path);

    void printPathToHere();

    bool compSolution(std::vector< std::vector<char> > &goalmap);

    bool compSolution(node &other);

    bool operator==(node &other);

    bool operator!=(node &other);

    void updateHeuristic(std::vector< std::vector<char> > &heuristicmap);

private:

    void makeKey();

    // variables to store
    // cost and heuristic cost
    int cost_, heuristic_;
    // the position of the diamonds
    std::vector< pos_t > diamonds_;
    // the robots position on the map
    pos_t robot_pos_;
    // the node the robot came from
    node * parent_;
    // the unique key for this node
    std::string key_;
    // the path taken to get her from the parent node
    std::string path_;
};


// comparator used for the graph > heap, to find the next leaf to consider
struct Comp
{
   bool operator()( node * a, node * b)
   {
       return (a->getCost() + a->getHeuristic()) > (b->getCost() + b->getHeuristic());
   }
};


// make the graph
class graph
{
public:
    graph(){
        std::make_heap(leafs_.begin(), leafs_.end(), Comp()); //
    }

    // -- add/get children function, to expand tree --
    // adds a child(ren) to the node parent in the graph and adds them to the leafs_

    // creats the child and add it to the heap, used in A* to get next shortest option
    void createChild(node &obj);

    // add the child to final graph (adds the entry in the hash table)
    void addChild(node* &obj);

    // deletes the child (used when an identical node was already found to remove this option from memory)
    void deleteChild(node* &obj);

    // get next child from the hash
    bool getNextChild(node * &nextChild);

    // test node existence
    bool nodeUnique(node &other);

    // get some stats
    int getClosedListSize(){
        return data_.size();
    }

private:
    std::vector< node * > leafs_;
    std::unordered_map< std::string, node* > data_;
};



#endif // GRAPH_H
