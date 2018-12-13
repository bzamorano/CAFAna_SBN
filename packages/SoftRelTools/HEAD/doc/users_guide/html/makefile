all : commands

%.html : ../../../man/%.1
	man2html $(<) > $(@)



commands : $(addsuffix .html, $(basename $(notdir $(wildcard ../../../man/*.1) ) ) )
	
addpkg.html : ../../../man/addpkg.1

freezerel.html : ../../../man/freezerel.1

lnkpkg.html : ../../../man/lnkpkg.1

newdist.html : ../../../man/newdist.1

newpkg.html : ../../../man/newpkg.1

newrel.html : ../../../man/newrel.1

newver.html : ../../../man/newver.1

pkgstatus.html : ../../../man/pkgstatus.1

rmpkg.html : ../../../man/rmpkg.1

srt_environment.html : ../../../man/srt_environment.1

srt_freeze.html : ../../../man/srt_freeze.1

srt_setup.html : ../../../man/srt_setup.1

clean:
	- rm -f $(addsuffix .html, $(basename $(notdir $(wildcard ../../../man/*.1) ) ) )      
