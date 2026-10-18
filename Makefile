# Makefile for COS284 Assembly Practical 4

ASM      = yasm
ASMFLAGS = -f elf64 -g dwarf2

TARGETS  = task1 task2
OBJECTS  = $(TARGETS:=.o)
SOURCES  = $(TARGETS:=.asm)

HARNESS  = main.c
PROGRAM  = dfa

# -no-pie: easier to debug while bringing the asm up.
# Remove it once things work if you want to verify PIE-compat too.
CFLAGS   = -g -O0 -Wall -Wextra -no-pie

.PHONY: all clean run zip

all: $(PROGRAM)

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

# Build the local test executable with gcc (NOT ld), so libc is linked.
$(PROGRAM): $(OBJECTS) $(HARNESS)
	gcc $(CFLAGS) -o $@ $(HARNESS) $(OBJECTS)

run: $(PROGRAM)
	./$(PROGRAM)

zip: clean
	zip u25004141.zip $(SOURCES)

clean:
	rm -f $(OBJECTS) $(PROGRAM) u25004141.zip