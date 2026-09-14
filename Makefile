PLATFORM_SRC = $(wildcard patches/*.c)
SRC = $(wildcard src/*.c)

OBJDIR = obj

PLATFORM_OBJS = $(patsubst patches/%.c,$(OBJDIR)/patches/%.o,$(PLATFORM_SRC))
OBJS = $(patsubst src/%.c,$(OBJDIR)/%.o,$(SRC)) $(PLATFORM_OBJS)

PLOOSHFINDER = plooshfinder/libplooshfinder.a

INCLDIRS = -I./include -I./plooshfinder/include

CC ?= clang
AR ?= ar
RANLIB ?= ranlib

CFLAGS ?= -O2
LDFLAGS ?=
LIBS = -lplooshfinder

# Enable with: make UNIVERSAL=1

UNIVERSAL ?= 0

ifeq ($(UNIVERSAL),1)
	ARCH_FLAGS = -arch x86_64 -arch arm64
else
	ARCH_FLAGS =
endif

CFLAGS += $(ARCH_FLAGS)
LDFLAGS += $(ARCH_FLAGS) -L./plooshfinder

.PHONY: all dirs clean submodules

all: dirs $(PLOOSHFINDER) $(OBJS) KPlooshFinder

submodules:
	@git submodule update --init --remote --recursive || true

dirs:
	@mkdir -p $(OBJDIR)
	@mkdir -p $(OBJDIR)/patches

clean:
	@rm -rf KPlooshFinder obj
	@$(MAKE) -C plooshfinder clean

KPlooshFinder: $(OBJS) $(PLOOSHFINDER)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) $(LIBS) -o $@

$(OBJDIR)/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLDIRS) -c -o $@ $<

$(OBJDIR)/patches/%.o: patches/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLDIRS) -c -o $@ $<

$(PLOOSHFINDER):
	$(MAKE) -C plooshfinder UNIVERSAL=$(UNIVERSAL) CC="$(CC)" CFLAGS="$(CFLAGS)"
