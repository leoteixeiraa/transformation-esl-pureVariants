#ifndef __ClassC__
#define __ClassC__

#include <iostream>

class ClassC {
public:
  ClassC() { std::cout<<(void*)this<<": Class C created"<<std::endl; }
  ~ClassC() { std::cout<<(void*)this<<": Class C deleted"<<std::endl; }
};

#endif /* __ClassC__ */
