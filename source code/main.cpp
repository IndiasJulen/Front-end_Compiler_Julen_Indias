#include <stdio.h>
#include <iostream>

extern int yyparse();
using namespace std;

int main(int argc, char **argv)
{
  cout << "started..." << endl ;
  yyparse();
  cout << "finished..." << endl ;
  cout << "" << endl ;
  return 0;
}
