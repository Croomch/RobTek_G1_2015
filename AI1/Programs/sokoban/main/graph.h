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
    node():parent_(nullptr),cost_(0),heuristic_(0){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int cost):cost_(cost),parent_(nullptr),heuristic_(0){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int cost, node * &parent):cost_(cost),parent_(parent),heuristic_(0){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
    }
    node(int element, node * &parent, std::vector< std::vector<char> > &heuristicmap):cost_(element),parent_(parent){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
        makeKey();
        updateHeuristic(heuristicmap);
    }
    node(const node &init){
        *this = init;
        makeKey();
    }

    int getCost(){return cost_;}
    int getHeuristic(){return heuristic_;}

    std::string * getKey(){ return &key_;}

    void setCost(int element_in){
        cost_ = element_in;
    }
    void setRobot(pos_t pos){
        robot_pos_ = pos;
        makeKey();
    }
    void setParent(node * &parent){
        parent_= parent;
    }
    void setDiamonds(std::vector< pos_t > &diamonds){
        diamonds_ = diamonds;
        makeKey();
    }
    node* getParent(){return parent_;}
    std::vector< pos_t > * getDiamonds(){return &diamonds_;}
    pos_t * getRobotPos(){return &robot_pos_;}

    void printPathToHere(){
        if(parent_ != nullptr){
            parent_->printPathToHere();
        }
        robot_pos_.print();
        std::cout << " " << cost_ << std::endl;
    }

    bool compSolution(std::vector< std::vector<char> > &goalmap){
        bool ret = false;
        int matches = 0;
        for(int d = 0; d < diamonds_.size(); d++){
            if(MAP_IS_GOAL(goalmap[diamonds_[d].y_][diamonds_[d].x_])){
                matches++;
            }
        }
        if(matches == diamonds_.size()){
            ret = true;
        }
        return ret;
    }

    bool compSolution(node &other){
        std::vector< pos_t >* goals = other.getDiamonds();
        bool ret = false;
        int matches = 0;
        for(int d = 0; d < diamonds_.size(); d++){
            for(int g = 0; g < goals->size(); g++){
                if(diamonds_[d] == (*goals)[g]){
                    matches++;
                }
            }
        }
        if(matches == diamonds_.size()){
            ret = true;
        }
        ret = ret & ((*other.getRobotPos()) == (*getRobotPos()));

        return ret;
    }

    bool operator==(node &other)
    {
        bool ret = compSolution(other);

        return ret;
    }

    bool operator!=(node &other)
    {
        bool ret = !(*this == other);

        return ret;
    }

    void updateHeuristic(std::vector< std::vector<char> > &heuristicmap){
        int cost = 0;
        for(int d = 0; d < diamonds_.size(); d++){
            cost += heuristicmap[diamonds_[d].y_][diamonds_[d].x_] - MAP_WALKABLE;
        }

        heuristic_ = cost;
    }

private:

    void makeKey(){
        std::string key = "";

        std::sort (diamonds_.begin(),diamonds_.end());
        for(int i = 0; i < diamonds_.size(); i++){
            key += (diamonds_[i]).x_;
            key += (diamonds_[i]).y_;
        }
        key += robot_pos_.x_;
        key += robot_pos_.y_;
        key_ = key;
    }

    int cost_, heuristic_;
    std::vector< pos_t > diamonds_;
    pos_t robot_pos_;
    node * parent_;
    std::string key_;
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
    void createChild(node &obj){
        node * _child = new node(obj);
        leafs_.push_back(_child);
        std::push_heap(leafs_.begin(), leafs_.end(), Comp());
    }

    void addChild(node* &obj){
        std::string * key = obj->getKey();
        data_[*key] = obj;
    }

    void deleteChild(node* &obj){
        delete obj;
    }
    //void addChild(std::vector< T > &children_in, const node< T > *parent_in);

    // get next child
    bool getNextChild(node * &nextChild){
        bool ret = false;
        if (leafs_.size() > 0){
            node * front = leafs_.front();
            std::pop_heap (leafs_.begin(),leafs_.end(), Comp());
            leafs_.pop_back();
            nextChild = front;
            ret = true;
        }
        return ret;
    }

    // test node existence
    bool nodeUnique(node &other){
        bool ret = false;
        std::unordered_map< std::string, node* >::iterator iter = data_.find((*(other.getKey())));

        if(iter == data_.end()){
            ret = true;
        }

        return ret;
    }

private:
    std::vector< node * > leafs_;
    std::unordered_map< std::string, node* > data_;
};



#endif // GRAPH_H
