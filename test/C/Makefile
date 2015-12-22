# Copyright 2004 Kalin Kozhuharov (kalin@thinrope.net)
# Copyright 2004 Gabor Bakos (baga@users.sourceforge.net)
# Created by Kalin Kozhuharov (kalin@thinrope.net)
# Modified by Gabor Bakos

PARSER=/bin/true
PARSER_OUT = parsed
PARSER_IN  = c

VIEW = yes


all:	function.$(PARSER_OUT)
	@echo "###"
	@echo "### Not yet implemented"
	@echo "###"

%.$(PARSER_OUT): %.$(PARSER_IN)
	$(PARSER) < $< > $@
ifeq ($(VIEW),yes)
	cat $@
endif

distclean:
	rm -f *.$(PARSER_OUT)

.PHONY:	distclean
