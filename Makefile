VERBOSE=1
DEBUG=1

ifdef VERBOSE
	Q =
	E = @true 
else
	Q = @
	E = @echo 
endif

CFILES:=$(shell find src -mindepth 1 -maxdepth 10 -name "*.c")
CXXFILES:=$(shell find src -mindepth 1 -maxdepth 10 -name "*.cpp")

INFILES:=$(CFILES) $(CXXFILES)
OBJFILES:=$(CFILES:src/%.c=%) $(CXXFILES:src/%.cpp=%)
DEPFILES:=$(CFILES:src/%.c=%) $(CXXFILES:src/%.cpp=%)
OFILES:=$(OBJFILES:%=obj/%.o)

BINFILE=test

COMMONFLAGS=-Wall -Wextra -pedantic $(shell sdl2-config --cflags)
LDFLAGS=-lpthread $(shell sdl2-config --libs) -lSDL2_ttf -lSDL2_image

ifdef DEBUG
        COMMONFLAGS := $(COMMONFLAGS) -g
endif

CC=clang++
CFLAGS=$(COMMONFLAGS) -O3 --std=c++14 -I ./src/include/ -I ./lib/include/ -I ./simpleini/

all: $(BINFILE)

.PHONY: clean all depend
.SUFFIXES:
obj/%.o: lib/%.cpp
	$(E)CXX-compiling $<
	$(Q)if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ -c $< $(CFLAGS)

obj/%.o: lib/%.c
	$(E)C-compiling $<
	$(Q)if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ -c $< $(CFLAGS)

obj/%.o: src/%.cpp
	$(E)CXX-compiling $<
	$(Q)if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ -c $< $(CFLAGS)

obj/%.o: src/%.c
	$(E)C-compiling $<
	$(Q)if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ -c $< $(CFLAGS)

Makefile.dep: $(CFILES)
	$(E)Depend
	$(Q)for i in $(^); do $(CC) $(CFLAGS) -MM "$${i}" -MT obj/`basename $${i%.*}`.o; done > $@

$(BINFILE): $(OFILES)
	$(E)Linking $@
	$(Q)$(CC) -o $@ $(OFILES) $(LDFLAGS)

clean:
	$(Q)rm -rf $(BINFILE) obj Makefile.dep

