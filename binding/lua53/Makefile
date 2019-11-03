CC = gcc
CFLAGS = -O2 -fPIC -Wall
LUADIR ?= /usr/local/include
TARGET = protobuf.so

.PHONY : all clean

all : $(TARGET)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
	SHARED_LIB = -dynamiclib -Wl,-undefined,dynamic_lookup
else
	SHARED_LIB = -shared
endif

$(TARGET) : pbc-lua53.c
	$(CC) $(CFLAGS) $(SHARED_LIB) -o $@ -I../.. -I$(LUADIR) -L../../build $^ -lpbc

clean :
	rm -f $(TARGET)
