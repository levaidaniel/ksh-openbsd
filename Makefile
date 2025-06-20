ifdef $(PREFIX)
PREFIX =	$(PREFIX)
else
PREFIX =	/usr
endif
BINDIR = 	$(DESTDIR)/$(PREFIX)/bin
MANDIR =	$(DESTDIR)/$(PREFIX)/man
TMP ?= /tmp

PROG =	ksh
SRCS =	alloc.c c_ksh.c c_sh.c c_test.c c_ulimit.c edit.c emacs.c eval.c \
	exec.c expr.c history.c io.c jobs.c lex.c mail.c main.c \
	misc.c path.c shf.c syn.c table.c trap.c tree.c tty.c var.c \
	version.c vi.c vis.c
OBJS =	alloc.o c_ksh.o c_sh.o c_test.o c_ulimit.o edit.o emacs.o eval.o \
	exec.o expr.o history.o io.o jobs.o lex.o mail.o main.o \
	misc.o path.o shf.o syn.o table.o trap.o tree.o tty.o var.o \
	version.o vi.o vis.o

CDIAGFLAGS=	-Wall -Wpointer-arith -Wuninitialized -Wstrict-prototypes
CDIAGFLAGS+=	-Wmissing-prototypes -Wunused -Wsign-compare
CDIAGFLAGS+=	-Wshadow
CDIAGFLAGS+=	-Wdeclaration-after-statement

CFLAGS +=	$(CDIAGFLAGS) `getconf LFS_CFLAGS` -DEMACS -DVI `pkg-config --cflags ncurses`
LDADD +=	-lbsd `pkg-config --libs ncurses`

$(PROG): $(OBJS)
	$(CC) $(OBJS) $(LDADD) $(CFLAGS) \
		-o $(PROG)

all: $(PROG)

check test:
	/usr/bin/perl tests/th -s tests -p ./ksh -T $(TMP) \
		-C pdksh,sh,ksh,posix,posix-upu
	cd tests/edit  &&  make all  &&  ./test.sh

install:
	install -m755 -d $(BINDIR)
	install -m755 --strip --no-target-directory ksh $(BINDIR)/pdksh
	install -m755 -d $(MANDIR)/man1
	install -m644 --no-target-directory ksh.1 $(MANDIR)/man1/pdksh.1
	install -m644 --no-target-directory sh.1 $(MANDIR)/man1/pdksh-sh.1

clean:
	rm -f $(OBJS) $(PROG)
