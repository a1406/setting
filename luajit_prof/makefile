all: test test2

LUAPATH=luajit2

test: test.cpp ${LUAPATH}/src/libluajit.a
	g++ -g -I${LUAPATH}/src -O0 -o test test.cpp ${LUAPATH}/src/libluajit.a -lm -ldl

test2: test2.cpp 
	g++ -g  -O0 -o test2 test2.cpp

clean:
	rm -f test test2

## ./flamegraph.pl --reverse /tmp/2.log > /tmp/2.svg
