# Edit only the following line
SRT_DIST=/sbnd/app/users/bzamoran/sbncode-v07_11_00/srcs/sbncode/lblpwgtools/code/CAFAna

export SRT_DIST
DEFAULT_SRT_DIST=/sbnd/app/users/bzamoran/sbncode-v07_11_00/srcs/sbncode/lblpwgtools/code/CAFAna
export DEFAULT_SRT_DIST

srt_setup () {
        . `srt_environment -X "$@"`
}
PATH=$SRT_DIST/releases/boot/bin/generic:$PATH
export PATH
