#!/bin/sh


LOCAL_DIR=/home/daniell/stuff/progs/ksh-openbsd
REMOTE_DIR=/home/daniell/stuff/progs/ksh-OpenBSD/ksh
export SEQ=0

for src in *.c *.h;do
	#echo "${src}:"

	REVISION_HDR=$(fgrep -he '$OpenBSD: ' "${LOCAL_DIR}/${src}")
	#echo "${REVISION_HDR}"
	typeset -i REVISION_LOCAL=$(echo "${REVISION_HDR}" |sed -r -e "s/^.*\\\$OpenBSD: ${src},v ([0-9]+\.[0-9]+).*$/\1/" |cut -d. -f2)
	#echo "${REVISION_LOCAL}"

	REVISION_HDR=$(fgrep -he '$OpenBSD: ' "${REMOTE_DIR}/${src}")
	#echo "${REVISION_HDR}"
	typeset -i REVISION_REMOTE=$(echo "${REVISION_HDR}" |sed -r -e "s/^.*\\\$OpenBSD: ${src},v ([0-9]+\.[0-9]+).*$/\1/" |cut -d. -f2)
	#echo "${REVISION_REMOTE}"

	if [ ${REVISION_LOCAL} -lt ${REVISION_REMOTE} ];then
		printf "${src}:\n\t1.${REVISION_LOCAL} is -lt 1.${REVISION_REMOTE}\n"
		{
			cd "${REMOTE_DIR}"

			while [ ${REVISION_LOCAL} -lt ${REVISION_REMOTE} ];do
				printf "\tDiffing r1.${REVISION_LOCAL} - r1.$(( REVISION_LOCAL + 1 ))\n"

				DIFF_FILENAME="${SEQ}-${src}_r1.${REVISION_LOCAL}-r1.$(( REVISION_LOCAL + 1 ))".diff

				cvs -q log -N -r1.$(( REVISION_LOCAL + 1 )) "${src}" > "${DIFF_FILENAME}" 2>/dev/null
				cvs -q diff -puN -r1.${REVISION_LOCAL} -r1.$(( REVISION_LOCAL + 1 )) "${src}" >> "${DIFF_FILENAME}" 2>/dev/null
				sed -i -n '/^----------------------------$/,$p' "${DIFF_FILENAME}"

				REVISION_LOCAL=$(( REVISION_LOCAL + 1 ))
				SEQ=$(( SEQ + 1 ))
			done
		}
	fi
done
