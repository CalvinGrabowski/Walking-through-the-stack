CFLAGS=-O0 -g -fno-omit-frame-pointer -I./include
LDFLAGS=-rdynamic -ldl -L./lib

AS_SRCS=$(shell find src/ -name '*.s')
C_SRCS=$(shell find src/ -name '*.c')
AS_OBJS=$(AS_SRCS:.s=.o)
C_OBJS=$(C_SRCS:.c=.o)

all: lib/libdebug.o test/main
	test/main

lib/libdebug.o: $(AS_OBJS) $(C_OBJS)
	ld -r -o $@ $^

test/main: test/main.c lib/libdebug.o
	$(LINK.c) -o $@ $^


