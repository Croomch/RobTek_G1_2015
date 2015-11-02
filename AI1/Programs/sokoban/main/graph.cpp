#include "graph.h"


void node::printPathToHere(){
    if(parent_ != nullptr){
        parent_->printPathToHere();
    }
    robot_pos_.print();
    std::cout << " " << cost_ << ", going: " << path_ << std::endl;
}

void node::getPathToHere(std::string &path){
    if(parent_ != nullptr){
        parent_->getPathToHere(path);
    }
    path += path_;

}

bool node::compSolution(std::vector< std::vector<char> > &goalmap){
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


bool node::compSolution(node &other){
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


void node::updateHeuristic(std::vector< std::vector<char> > &heuristicmap){
    int cost = 0;
    for(int d = 0; d < diamonds_.size(); d++){
        cost += heuristicmap[diamonds_[d].y_][diamonds_[d].x_] - MAP_WALKABLE;
    }

    heuristic_ = cost;
}


bool node::operator!=(node &other)
{
    bool ret = !(*this == other);

    return ret;
}


bool node::operator==(node &other)
{
    bool ret = compSolution(other);

    return ret;
}


void node::makeKey(){
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


void graph::createChild(node &obj){
    node * _child = new node(obj);
    leafs_.push_back(_child);
    std::push_heap(leafs_.begin(), leafs_.end(), Comp());
}

void graph::addChild(node* &obj){
    std::string * key = obj->getKey();
    data_[*key] = obj;
}

void graph::deleteChild(node* &obj){
    delete obj;
}
//void addChild(std::vector< T > &children_in, const node< T > *parent_in);

// get next child
bool graph::getNextChild(node * &nextChild){
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
bool graph::nodeUnique(node &other){
    bool ret = false;
    std::unordered_map< std::string, node* >::iterator iter = data_.find((*(other.getKey())));

    if(iter == data_.end()){
        ret = true;
    }

    return ret;
}
