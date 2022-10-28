TYPE:=

CC=gcc
OBJCOPY=objcopy
BASEURL=https://justine.lol/cosmopolitan

ifeq ($(TYPE),)
AMALGAMATION=cosmopolitan-amalgamation-2.1.1.zip
LIBCOSMO_SHA256_EXPECTED=\
b36781c7cd6763402c085f29e31ab53f5df4c066dbdde83c808dea978757115a
else ifeq ($(TYPE),release)
AMALGAMATION=cosmopolitan-amalgamation-rel-2.1.1.zip
LIBCOSMO_SHA256_EXPECTED=\
4fbdf08a0304778714c17871760976ac0171066be8181eb9765d6f5e1d1c18c7
else ifeq ($(TYPE),tiny)
AMALGAMATION=cosmopolitan-amalgamation-tiny-2.1.1.zip
LIBCOSMO_SHA256_EXPECTED=\
2c93ba18c7556c3aa03ea30f563a271abdd343a7ec9c06a4c351244e6139d6cc
else
	_CHEAT_ARG := $(info Please give the right TYPE: TYPE=, TYPE=release, TYPE=tiny)
	exit 1
endif

BUILDTARGET = kilo$(TYPE).com
LIBCOSMOTARGET = libcosmo$(TYPE)

CFLAG :=

all: $(BUILDTARGET)

$(BUILDTARGET): $(LIBCOSMOTARGET) $(wildcard *.c)
	mkdir -p build
	cp build/$(BUILDTARGET).dbg build/$(BUILDTARGET).dbg.old 2>/dev/null || :
	cp build/$(BUILDTARGET) build/$(BUILDTARGET).old 2>/dev/null || :
	$(CC) -g -Os -static -fno-pie -no-pie -nostdlib -nostdinc                  \
		-fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -o   \
		build/$(BUILDTARGET).dbg *.c -Wl,--gc-sections -fuse-ld=bfd -Wl,--gc-sections \
		-Wl,-T,$(LIBCOSMOTARGET)/ape.lds -include $(LIBCOSMOTARGET)/cosmopolitan.h         \
		$(LIBCOSMOTARGET)/crt.o $(LIBCOSMOTARGET)/ape-no-modify-self.o                     \
		$(LIBCOSMOTARGET)/cosmopolitan.a -Iinclude_stub/ $(CFLAG)
	$(OBJCOPY) -S -O binary build/$(BUILDTARGET).dbg build/$(BUILDTARGET)
	@echo
	@echo The cross-platform application is \"build/$(BUILDTARGET)\"
	@echo The native application is \"build/$(BUILDTARGET).dbg\"
	@echo

$(LIBCOSMOTARGET): $(AMALGAMATION)
	@libcosmo_sha256_actual=`sha256sum $(AMALGAMATION) | cut -d ' ' -f 1`; \
echo "expected sha256sum: $(LIBCOSMO_SHA256_EXPECTED)" && echo \
"actual   sha256sum: $$libcosmo_sha256_actual"; if	 \
[ "$$libcosmo_sha256_actual" = "$(LIBCOSMO_SHA256_EXPECTED)" ]; then echo \
"checksums match"; else echo "checksums don't match, aborting" && exit 1; fi;
	unzip -d $(LIBCOSMOTARGET) $(AMALGAMATION)

$(AMALGAMATION):
	wget "$(BASEURL)/$(AMALGAMATION)"

cleanall: clean distclean

clean:
	rm -rf build/

distclean: clean
	rm -rf cosmopolitan* libcosmo*

help:
	@echo
	@echo Cosmopolitan compilation Automated Make:
	@echo
	@echo "\t\"make\" or \"make TYPE=\" to build the default version"
	@echo "\t\"make TYPE=release\" to build the release version for closed source project"
	@echo "\t\"make TYPE=tiny\" to build the tiny version for the minimum size without all the redundant features"
	@echo "\t\"make all_types\" to build the all versions of the program"
	@echo "\t\"make cleanall\" to remove all the generated objects"
	@echo "\t\"make clean\" to remove the build binaries"
	@echo "\t\"make distclean\" to remove all the downloaded Cosmopolitan dependencies"
	@echo

all_types:
	make
	make TYPE=release
	make TYPE=tiny