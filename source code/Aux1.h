#ifndef AUX1_H_
#define AUX1_H_

#include <string>
#include <set>
#include <vector>
#include <list>

typedef std::list<std::string> IdList;
typedef std::list<int> RefList;

struct expressionstruct {
  std::string name;
  RefList trueL;  // true is a key-word in c
  RefList falseL; // false is a key-word in c
};

struct skipexitstruct {
  RefList skip;
  RefList exit;
};

#define SINTEGER "ent"
#define SFLOAT "real"

#endif /* AUX_H_ */
