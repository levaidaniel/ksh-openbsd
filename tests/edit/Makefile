EDITP =	edit
EDIT =	edit.c
EDITO =	edit.o

VISP =	vis
VIS =	vis.c foldit.c
VISO =	vis.o foldit.o

LDADD =	-lbsd

$(VISP): $(VISO)
	$(CC) -o $(VISP) $(LDADD) \
		$(VISO)

$(EDITP): $(EDITO)
	$(CC) -o $(EDITP) $(LDADD) \
		$(EDITO)

all: $(VISP) $(EDITP)

clean:
	rm -f $(EDITO) $(EDITP) $(VISO) $(VISP)
