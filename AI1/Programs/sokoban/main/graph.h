#ifndef GRAPH_H
#define GRAPH_H

#include <vector>
#include <algorithm>
#include <iostream>

struct pos_t{
    char x, y;
    pos_t():x(0),y(0){}
    bool operator== (const pos_t &other){
        bool ret = false;
        if(x == other.x && y == other.y){
            ret = true;
        }
        return ret;
    }
    void print(){
        std::cout << y << std::endl;
    }
};



class node
{
public:
    node():parent_(nullptr){}
    node(int element):cost_(element),parent_(nullptr){}
    node(int element, node * parent):cost_(element),parent_(parent){}
    node(node &init){*this = init;}

    int getCost(){return cost_;}
    void setData(int &element_in){cost_ = element_in;}
    node* getParent(){return parent_;}
    std::vector< pos_t > * getDiamonds(){return &diamonds_;}
    pos_t * getRobotPos(){return &robot_pos_;}

    void printPathToHere(){
        if(parent_ != nullptr){
            parent_->printPathToHere();
        }
        std::cout << " " << cost_;
    }

    int compSolution(std::vector< pos_t > &goals){
        int matches = 0;
        for(int g = 0; g < goals.size(); g++){
            for(int d = 0; d < diamonds_.size(); d++){
                if(goals[g] == diamonds_[d]){
                    matches++;
                }
            }
        }
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
        node * _child = new node(child_in, parent_in);
        leafs_.push_back(_child);
        std::push_heap(leafs_.begin(), leafs_.end(), Comp());
        //std::make_heap(leafs_.begin(), leafs_.end(), Comp());
    }
    //void addChild(std::vector< T > &children_in, const node< T > *parent_in);

    // get next child
    bool getNextChild(node * nextChild){
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
