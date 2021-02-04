PROBLEMSET := $(shell find . -name '*.cpp' | tr '\n' '\0' | 		\
	       xargs -0 -n 1 | 						\
	       awk '{ split($$0,a,".cpp"); print a[1]".o" }')
PROBLEMSET := $(PROBLEMSET) 						\
	      $(shell find . -name '*.java' | tr '\n' '\0' | 		\
	       xargs -0 -n 1 | 						\
	       awk '{ split($$0,a,".java"); print a[1]".class" }')

CXXFLAGS := -std=c++17 -Ofast -Werror -Wextra -Wno-sign-conversion -Wshadow
JAVAFLAGS := -Xlint:unchecked

FETCHID := tr '\n' '\0' | xargs -0 -n 1 basename | 			\
	   awk '{ split($$0,a,"."); print a[1] }'
MAINCLASS := awk '{ split($$0,a,".class"); print a[1] }'
CXX := g++
JAVA := java
JAVAC := javac

%.class: %.java
	@-echo "Run test for problem $(shell dirname $@):"
	@-echo "--------------------------------------------------------"
	@-echo ""
	@-$(JAVAC) $(JAVAFLAGS) $<
	@- $(foreach ID,$(shell ls -1c `dirname $@`/*.in | $(FETCHID)), \
		echo "\nTest $(ID):"; 					\
		$(JAVA) -cp `dirname $@` `basename $@ | $(MAINCLASS)` 	\
					< `dirname $@`/$(ID).in | 	\
		diff -y - `dirname $@`/$(ID).out;			\
	)
	@-echo "--------------------------------------------------------"
	@-echo ""
	@-echo ""
	@-find `dirname $@` -name '*.class' -delete

%.o: %.cpp
	@-echo "Run test for problem $(shell dirname $@):"
	@-echo "--------------------------------------------------------"
	@-echo ""
	@-$(CXX) $(CXXFLAGS) $< -o $@
	@- $(foreach ID,$(shell ls -1c `dirname $@`/*.in | $(FETCHID)), \
		echo "\nTest $(ID):"; 					\
		$@ < `dirname $@`/$(ID).in | 				\
		diff -y - `dirname $@`/$(ID).out;			\
	)
	@-echo "--------------------------------------------------------"
	@-echo ""
	@-echo ""
	@-rm -fr $@

all: $(PROBLEMSET)

clean:
	@-find . -name '*.o' -delete
	@-find . -name '*.class' -delete
