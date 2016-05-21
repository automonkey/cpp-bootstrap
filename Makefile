.PHONY: all dep clean test valtest default

default: all test

all: lib app libut

include global.mk

Dir := lib/impl
include lib/make/lib.mk

Dir := app/impl
include app/make/app.mk

Dir := lib-ut/impl
include lib-ut/make/lib-ut.mk

include $(DEP_FILES)

dep: $(DEP_FILES)

clean:
	-rm $(CLEAN_FILES)

test: $(TEST_FILES)
	@for tst in $^; do echo Running test $$tst; $$tst; done;

valtest: $(TEST_FILES)
	@for tst in $^; do echo Running test $$tst under valgrind;\
	 valgrind -q --error-exitcode=1 --leak-check=full $$tst; done;

