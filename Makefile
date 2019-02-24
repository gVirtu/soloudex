ERLANG_PATH := $(shell elixir -e "IO.puts :code.root_dir")
ERLANG_LIBRARY := ${ERLANG_PATH}/usr/lib
ERLANG_INCLUDE := ${ERLANG_PATH}/usr/include
ERLANG_OBJECTS := ei

INCLUDED_FILES = ${ERLANG_INCLUDE}
INCLUDED_FILES += include

LIBRARY_PATHS = ${ERLANG_LIBRARY}
LIBRARY_PATHS += priv/lib

LIBRARIES = ${ERLANG_OBJECTS}

ifeq ($(TRAVIS),true)
	LIBRARIES += soloud_static pthread
else
	LIBRARIES += soloud_static pthread asound
endif

SRC = $(wildcard src/*.cpp)
OBJ = $(SRC:.cpp=.o)

CC_PLIB = $(foreach plib, $(LIBRARY_PATHS), -L$(plib))
CC_PINC = $(foreach pinc, $(INCLUDED_FILES), -I$(pinc))
CC_LIBS = $(foreach obj, $(LIBRARIES), -l$(obj))

# $(info $$CC_LIBS is [${CC_LIBS}])
# $(info $$CC_PLIB is [${CC_PLIB}])
# $(info $$CC_PINC is [${CC_PINC}])
# $(info $$CXX is [${CXX}])

DEFAULT_TARGETS ?= cpp_priv priv/cpp/soloud

CXXFLAGS = -std=c++11 $(CC_PINC) $(CC_PLIB) $(CC_LIBS)

priv/cpp/soloud: cpp_priv $(OBJ)
	$(CXX) -std=c++11 -D MAX_WAVSTREAMS=$(MAX_WAVSTREAMS) $(SRC) -o priv/cpp/soloud $(CC_PINC) $(CC_PLIB) $(CC_LIBS)

cpp_priv:
	mkdir -p priv/cpp

clean:
	rm -rf priv/cpp $(OBJ) $(BEAM_FILES)
