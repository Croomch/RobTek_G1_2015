#ifndef GRAPH_H
#define GRAPH_H

#include <vector>
#include <algorithm>
#include <iostream>

#define MAP_FREE 0
#define MAP_WALL 1
#define MAP_GOAL 2
#define MAP_WALKABLE 3
#define MAP_IS_WALKABLE(x) (x>=MAP_WALKABLE)?true:false
#define MAP_IS_GOAL(x) (x==MAP_GOAL)?true:false
#define MAP_IS_WALL(x) (x==MAP_WALL)?true:false
#define MAP_IS_EMPTY(x) (x==MAP_FREE)?true:false

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
    void print(){
        std::cout << "{" << (int)x_ << ", " << (int)y_ << "}";
    }
};



class node
{
public:
    node():parent_(nullptr){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
    }
    node(int element):cost_(element),parent_(nullptr){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
    }
    node(int element, node * &parent):cost_(element),parent_(parent){
        robot_pos_.x_ = 0;
        robot_pos_.y_ = 0;
    }
    node(const node &init){*this = init;}

    int getCost(){return cost_;}
    void setCost(int element_in){
        cost_ = element_in;
    }
    void setRobot(pos_t pos){
        robot_pos_ = pos;
    }
    void setParent(node * &parent){
        parent_= parent;
    }
    void setDiamonds(std::vector< pos_t > &diamonds){
        diamonds_ = diamonds;
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

private:
    int cost_;
    std::vector< pos_t > diamonds_;
    pos_t robot_pos_;
    node * parent_;
};

struct Comp
{
   bool operator()( node * a, node * b)
   {
       return (a->getCost()) > (b->getCost());
   }
};



class graph
{
public:
    graph(){
        std::make_heap(leafs_.begin(), leafs_.end(), Comp()); //
    }

    // -- add/get children function, to expand tree --
    // adds a child(ren) to the node parent in the graph and adds them to the leafs_
    void addChild(int &child_in, node *parent_in = nullptr){
        node _child(child_in, parent_in);
        addChild(_child);
    }
    void addChild(node &obj){
        node * _child = new node(obj);
        leafs_.push_back(_child);
        std::push_heap(leafs_.begin(), leafs_.end(), Comp());
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

    // -- traverse tree --


    // -- modify children --



private:
    std::vector< node * > leafs_;
    //node<T> * root_;

};



#endif // GRAPH_H
