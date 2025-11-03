#include "ClassA.h"
#include "ClassB.h"
#include "ClassC.h"
#include "ClassD.h"
#include "ClassE.h"
#include "config.h"

int main() {
  std::cout << "Creating classA" << std::endl;	
  ClassA *a; a = new ClassA;
  std::cout << std::endl << "Creating classB" << std::endl;
  ClassB *b; b = new ClassB;
  std::cout << std::endl << "Creating classC" << std::endl;
  ClassC *c; c = new ClassC;
  std::cout << std::endl << "Creating classD" << std::endl;
  ClassD *d; d = new ClassD;
  std::cout << std::endl << "Creating classE" << std::endl;
  ClassE *e; e = new ClassE;
  
  std::cout << std::endl << "Deleting classA" << std::endl;
  delete a;
  std::cout << std::endl << "Deleting classB" << std::endl;
  delete b;
  std::cout << std::endl << "Deleting classC" << std::endl;
  delete c;
  std::cout << std::endl << "Deleting classD" << std::endl;
  delete d;
  std::cout << std::endl << "Deleting classE" << std::endl;
  delete e;
  return 0;
}
