# Practice scaffold: implement this Makefile yourself.
# See README.md for requirements, experiments, and acceptance criteria.
# TODO: Define compiler, preprocessor, compiler, and linker variables.
# TODO: Compile each source file into a separate object under build/.
# TODO: Link build/sensor-demo from those objects.
# TODO: Track header dependencies and support incremental builds.
# TODO: Implement all, test, clean, and install targets.
# TODO: Support PREFIX and DESTDIR for installation without root access.

CC = gcc
CPPFLAGS = -Iinclude
CFLAGS = -Wall -Wextra -g
LDFLAGS =
LDLIBS =

PREFIX ?= /usr/local
DESTDIR ?=

TARGET := build/sensor-demo
OBJECTS := build/main.o build/sensor.o
DEPS := $(OBJECTS:.o=.d)

.PHONY: all test clean install

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

build/%.o: src/%.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

build:
	mkdir -p $@

test: $(TARGET)
	printf '%s\n' 'Embedded Linux training: 25 C' > build/expected.txt
	./$(TARGET) > build/actual.txt
	cmp build/expected.txt build/actual.txt
	@echo "Test passed"

clean:
	rm -rf build

install: $(TARGET)
	install -d "$(DESTDIR)$(PREFIX)/bin"
	install -m 755 "$(TARGET)" "$(DESTDIR)$(PREFIX)/bin/sensor-demo"

-include $(DEPS)