#kilo: kilo.c
#	$(CC) -o kilo kilo.c -Wall -W -pedantic -std=c99

#clean:
#	rm kilo

CC=gcc
OBJCOPY=objcopy
BASEURL=https://justine.lol/cosmopolitan
AMALGAMATION=cosmopolitan-amalgamation-2.1.1.zip
LIBCOSMO_SHA256_EXPECTED=\
b36781c7cd6763402c085f29e31ab53f5df4c066dbdde83c808dea978757115a

CFLAG :=

all: kilo.com

kilo.com: libcosmo kilo.c
	$(CC) -g -Os -static -fno-pie -no-pie -nostdlib -nostdinc                  \
		-fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -o   \
		kilo.com.dbg *.c -Wl,--gc-sections -fuse-ld=bfd -Wl,--gc-sections \
		-Wl,-T,libcosmo/ape.lds -include libcosmo/cosmopolitan.h         \
		libcosmo/crt.o libcosmo/ape-no-modify-self.o                     \
		libcosmo/cosmopolitan.a -Iinclude_stub/ $(CFLAG)
	$(OBJCOPY) -S -O binary kilo.com.dbg kilo.com

libcosmo: $(AMALGAMATION)
	@libcosmo_sha256_actual=`sha256sum $(AMALGAMATION) | cut -d ' ' -f 1`; \
echo "expected sha256sum: $(LIBCOSMO_SHA256_EXPECTED)" && echo \
"actual   sha256sum: $$libcosmo_sha256_actual"; if	 \
[ "$$libcosmo_sha256_actual" = "$(LIBCOSMO_SHA256_EXPECTED)" ]; then echo \
"checksums match"; else echo "checksums don't match, aborting" && exit 1; fi;
	unzip -d libcosmo $(AMALGAMATION)

$(AMALGAMATION):
	wget "$(BASEURL)/$(AMALGAMATION)"

clean:
	rm -f kilo.com.dbg kilo.com

distclean: clean
	rm -rf cosmopolitan* libcosmo
