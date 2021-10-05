CFLAGS=-Wall
CPPFLAGS=
CC= g++
SOURCES=parser.cpp main.cpp tokens.cpp Code.cpp

all: parser test

.PHONY: clean

clean:
	rm parser.cpp parser.hpp parser tokens.cpp *~

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $<

parser: $(SOURCES) Code.h Aux1.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(SOURCES)

test:  parser ../testcases/test1.in ../testcases/test2.in ../testcases/test3.in ../testcases/test4.in ../testcases/test5.in ../testcases/test6.in ../testcases/badtest1.in ../testcases/badtest2.in ../testcases/badtest3.in ../testcases/badtest4.in ../testcases/badtest5.in ../testcases/badtest6.in ../testcases/badtest7.in
	./parser <../testcases/test1.in
	./parser <../testcases/test2.in
	./parser <../testcases/test3.in
	./parser <../testcases/test4.in
	./parser <../testcases/test5.in
	./parser <../testcases/test6.in
	./parser <../testcases/badtest1.in
	./parser <../testcases/badtest2.in
	./parser <../testcases/badtest3.in
	./parser <../testcases/badtest4.in
	./parser <../testcases/badtest5.in
	./parser <../testcases/badtest6.in
	./parser <../testcases/badtest7.in
