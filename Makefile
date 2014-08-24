DECKLISTS := $(wildcard edh/*.deck leg/*.deck)
TXT_TARGETS   := $(DECKLISTS:.deck=.txt)
HTML_TARGETS  := $(DECKLISTS:.deck=.html) index.html
CLEAN         := $(TXT_TARGETS) $(HTML_TARGETS) index.html index.txt

#ASCIIDOC_OPTS=-f doc/asciidoc.conf
#	-a CONFDIR=$(CONFDIR) \
#	-a EXECDIR=$(EXECDIR) \
#	-a BINDIR=$(BINDIR) \
#	-a SERVER_DIR=$(SERVER_DIR) \
#	-a BUGREPORT=$(BUGREPORT) \
#	-a URL=$(URL) \
#	-a VERSION=$(VERSION) \
#	-a REPO='https://github.com/DMBuce/clicraft'

.PHONY: all
all: html

.PHONY: html
html: $(HTML_TARGETS)

edh/%.html: edh/%.txt
	#asciidoc ${ASCIIDOC_OPTS} -a icons -a max-width=960px $<
	asciidoc -a icons -a max-width=960px $<

edh/%.txt: edh/%.deck
	./bin/deck2asciidoc $< > $@

leg/%.html: leg/%.txt
	#asciidoc ${ASCIIDOC_OPTS} -a icons -a max-width=960px $<
	asciidoc -a icons -a max-width=960px $<

leg/%.txt: leg/%.deck bin/deck2asciidoc
	./bin/deck2asciidoc $< > $@

index.html: index.txt
	asciidoc -a toc -a icons -a max-width=960px $<

index.txt: bin/mkindex README.asciidoc
	./$< > $@

.PHONY: clean
clean:
	rm -f $(CLEAN)

.PHONY: test
test: edh/rakdos.html edh/rakdos.txt

