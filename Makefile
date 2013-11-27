ifdef ${PREFIX}
PREFIX=${PREFIX}
else
PREFIX=/usr
endif
BINDIR=${DESTDIR}/bin
MANDIR=${DESTDIR}${PREFIX}/man

PROG=	ksh
SRCS=	alloc.c c_ksh.c c_sh.c c_test.c c_ulimit.c edit.c emacs.c eval.c \
	exec.c expr.c history.c io.c jobs.c lex.c mail.c main.c mknod.c \
	misc.c path.c shf.c syn.c table.c trap.c tree.c tty.c var.c \
	version.c vi.c strlcpy.c strlcat.c
OBJS=	alloc.o c_ksh.o c_sh.o c_test.o c_ulimit.o edit.o emacs.o eval.o \
	exec.o expr.o history.o io.o jobs.o lex.o mail.o main.o mknod.o \
	misc.o path.o shf.o syn.o table.o trap.o tree.o tty.o var.o \
	version.o vi.o strlcpy.o strlcat.o

all: $(PROG)

CFLAGS+=-Wall
$(PROG): $(OBJS)
	gcc $(OBJS) -lbsd -o ksh

install:
	install -m755 -d $(BINDIR)
	install -m755 --strip --no-target-directory ksh $(BINDIR)/pdksh
	install -m755 -d $(MANDIR)/man1
	install -m644 --no-target-directory ksh.1 $(MANDIR)/man1/pdksh.1

clean:
	rm -f $(OBJS) $(PROG)

check test:
	/usr/bin/perl tests/th -s tests -p ./ksh -C \
	    pdksh,sh,ksh,posix,posix-upu
