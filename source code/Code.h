#ifndef CODE_H_
#define CODE_H_
#include <iostream>
#include <sstream>
#include <fstream>
#include <set>
#include <vector>
#include <list>
#include "Aux1.h"

/* Structure to manage the code that's going to be created, instead of directly writing the code, it'll be
 * stored in this structure, and in the end all of it will be written
 */

class Code {

private:

	/**************************/
	/*  INNER REPRESENTATION  */
	/**************************/

	/* Statements that define the code. */
	std::vector<std::string> statements;

	/* Method to create identificators, each time we create a new one, it increments by 1 */
	int nextId;

	/* Returns the number of the next statement, so that when we write all the code, each statement has it's own number */
	int nextStatement() const;

public:

	/******************************/
	/* METHODS TO MANAGE THE CODE */
	/******************************/

	/* Constructor */
	Code();

	/* Creates a new identificator, like "_t1, _t2, ..." and always different. */
	std::string newId() ;

	/* Adds a new statement into the structure. */
	void addStatement(const std::string &statement);

	/* Giving a variable list and a type, create the declaration statements and add them into the structure */
	void addDecls(const std::string &typeName, const IdList &idNames);

	/* Giving a parameter list, a type and a parameter type(in, out or inout), create the parameter declarations and add them into the structure */
	void addParams(const std::string &typeName, const IdList &idNames, const std::string &pType) ;


	/* Add the missing reference to the given statements.
	 * For example: "goto" => "goto 20;" being 20 a reference. */
	void completeStatement(RefList &statementNumbers, const int value);

	/* Writes the statements stored in the structure, in this case into the standard output. */
	void write();

	/* Returns the number of the next statement. */
	int getRef() const;

};

#endif /* CODE_H_ */
