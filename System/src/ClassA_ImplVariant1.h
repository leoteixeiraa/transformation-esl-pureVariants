#ifndef __ClassA_Impl__
#define __ClassA_Impl__

#include <iostream>

  ClassA::ClassA() { std::cout<<(void*)this<<": Class A (Variant 1) created"<<std::endl; }
  ClassA::~ClassA() { std::cout<<(void*)this<<": Class A (Variant 1) deleted"<<std::endl; }

#endif /* __ClassA_Impl__ */
