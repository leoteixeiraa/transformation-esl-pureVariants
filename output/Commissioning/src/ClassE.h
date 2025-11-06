#ifndef __ClassE__
#define __ClassE__

#include <iostream>
#include "ClassD.h"

class ClassE: ClassD {
public:
  ClassE() { std::cout<<(void*)this<<": Class E created"<<std::endl; }
  ~ClassE() { std::cout<<(void*)this<<": Class E deleted"<<std::endl; }
};

#endif /* __ClassE__ */
