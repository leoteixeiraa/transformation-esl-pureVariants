#ifndef __ClassB__
#define __ClassB__

#include <iostream>

class ClassB {
public:
  ClassB() { std::cout<<(void*)this<<": Class B (Variant 2) created"<<std::endl; }
  ~ClassB() { std::cout<<(void*)this<<": Class B (Variant 2) deleted"<<std::endl; }
};

#endif /* __ClassB__ */
