# Edit only the following line
setenv SRT_DIST /sbnd/app/users/bzamoran/sbncode-v07_11_00/srcs/sbncode/lblpwgtools/code/CAFAna

setenv DEFAULT_SRT_DIST $SRT_DIST
alias srt_setup source '`srt_environment -X -c \!*`'
setenv PATH $SRT_DIST/releases/boot/bin/generic:$PATH
