#include "Code.h"

using namespace std;


/*****************/
/*  Constructor  */
/*****************/

Code::Code() {
  nextId = 1;
}


/*******************/
/*  nextStatement  */
/*******************/

int Code::nextStatement() const {
  return statements.size() + 1;
}


/*********/
/* newId */
/*********/

string Code::newId() {
  stringstream stream;
  stream << "_t" << nextId++;
  return stream.str();
}


/****************/
/* addStatement */
/****************/

void Code::addStatement(const string &statementString) {
  stringstream statement;
  statement << nextStatement() << ": " << statementString;
  statements.push_back(statement.str());
}

/************/
/* addDecls */
/************/

void Code::addDecls(const string &typeName, const IdList &idNames) {
  IdList::const_iterator iter;
  for (iter=idNames.begin(); iter!=idNames.end(); iter++) {
    addStatement(string(typeName + " " + *iter));
  }
}

/**********************/
/*      adParams      */
/**********************/

void Code::addParams(const string &typeName, const IdList &idNames, const string &pType){ 
  string pTypeAux ;
  if      (pType == "in") pTypeAux = "val" ;
  else if (pType == "out") pTypeAux = "ref" ;
  else if (pType == "in out") pTypeAux = "ref" ;
  IdList::const_iterator iter;
  for (iter=idNames.begin(); iter!=idNames.end(); iter++) {
    addStatement(pTypeAux + "_" + typeName + " " + *iter);
  }
}

/*********************/
/* completeStatement */
/*********************/

void Code::completeStatement(RefList &statementNumbers, const int value) {
  stringstream stream;
  RefList::iterator iter;
  stream << " " << value;
  for (iter = statementNumbers.begin(); iter != statementNumbers.end(); iter++) {
    statements[*iter-1].append(stream.str());
  }
}


/**********/
/* write  */
/**********/

void Code::write() {
  vector<string>::const_iterator iter;
  for (iter = statements.begin(); iter != statements.end(); iter++) {
    cout << *iter << " ;" << endl;
  }
}


/**************/
/* getRef */
/**************/

int Code::getRef() const {
  return nextStatement();
}


