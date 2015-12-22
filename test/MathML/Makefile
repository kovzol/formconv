# Copyright 2004 Kalin Kozhuharov (kalin@thinrope.net)
# Copyright 2004 Gabor Bakos (baga@users.sourceforge.net)
# Created by Kalin Kozhuharov (kalin@thinrope.net)
# Modified by Gabor Bakos

PARSER = ../../bin/mathmlin
PARSER_IN  = xml
PARSER_OUT = parsed

SOURCES_IN  := sum vectors function a sphere
SOURCES_OUT := $(addsuffix .$(PARSER_OUT), $(SOURCES_IN))
SOURCES_C   := $(addsuffix .c, $(SOURCES_IN))

VIEW = no

all:	all_c

all_c:	$(SOURCES_C)

all_parsed:	$(SOURCES_OUT)

%.$(PARSER_OUT): %.$(PARSER_IN)
	$(PARSER) < $< > $@
ifeq ($(VIEW),yes)
	cat $@
endif

%.c: %.$(PARSER_OUT)
	cat $< | $(CC) -E - |grep -v "^#" |grep  . >$@

clean:
	rm -f *.$(PARSER_OUT)

distclean: clean
	rm -f *.c

.PHONY:	distclean clean
