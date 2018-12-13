all: users_guide.ps html

users_guide.ps: $(wildcard *.eps) users_guide.done
	dvips users_guide.dvi -o users_guide.ps
users_guide.dvi: users_guide.tex appendix.tex commands.tex users_guide.ind $(wildcard *.eps)
	latex users_guide
users_guide.done: users_guide.dvi
	if [ \
        "`grep -c 'Rerun to get cross-references right' users_guide.log`" = "1" \
        ]; then \
            rm -f users_guide.dvi ;\
            $(MAKE) users_guide.done;\
        else \
            touch users_guide.done;\
        fi
users_guide.ind:
	test -f users_guide.idx && makeindex users_guide || touch users_guide.ind

html: html/users_guide.html
	cd html; make

html/users_guide.html : users_guide.tex appendix.tex commands.tex users_guide.ind $(wildcard *.eps)
	latex2html -dir html users_guide.tex
	fix_url
	cp html/index.html  html/users_guide.html
	- cp html/* /afs/fnal.gov/files/docs/products/srt
	cp users_guide.ps /afs/fnal.gov/files/docs/products/srt

clean:
	rm -f users_guide.idx \
            users_guide.aux users_guide.ind users_guide.lof users_guide.log \
            users_guide.lot users_guide.ilg users_guide.toc users_guide.dvi \
            users_guide.done users_guide.ps html/*.html html/img*

