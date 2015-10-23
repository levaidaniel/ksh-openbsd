#!/bin/sh

if [ -z "$1" ];then
	echo 'tell me which patchset to start with'
	exit 1
fi

typeset -i PATCHSET=$1
LOCAL_DIR=/home/daniell/stuff/progs/ksh-openbsd
REMOTE_DIR=/home/daniell/stuff/progs/ksh-OpenBSD/ksh
IFS='
'

while true;do
	diff="${REMOTE_DIR}"/patchsets/${PATCHSET}.patch
	[ -r "${diff}" ]  ||  { echo "no patchset called ${diff}."; exit 1; }

	echo "===> ${PATCHSET} (${diff})"
	echo "Dry run:"
	patch -p3 --dry-run <"${diff}"

	echo -n "Apply ${PATCHSET}? (y/n) [y] "; read
	if [ "${REPLY}" != 'n' -a "${REPLY}" != 'N' ];then
		rm -f *.rej
		patch --no-backup-if-mismatch -p3 <"${diff}" || { ls -l *.rej; echo -n "failed to apply ${diff}. escape to shell, fix rejections, then get back here and press enter."; read; }
	fi

	echo "Build test:"
	make || { echo "the test build has failed. escape to shell, fix it, then get back here and press enter."; read; }

	# generate the commit message from the patchset's header
	typeset -i REACHED_LOG=0
	LOG_MESSAGE=''
	for line in $(< "${REMOTE_DIR}"/patchsets/"${PATCHSET}".patch);do
		# exit
		if echo "${line}" |egrep -q -e '^Index: '  ||  echo "${line}" |egrep -q -e '^--- ';then
			break
		fi

		if echo "${line}" |egrep -q -e '^Author: ';then
			AUTHOR=${line}
			continue
		fi
		if echo "${line}" |egrep -q -e '^Date: ';then
			DATE=${line}
			continue
		fi

		if echo "${line}" |egrep -q -e '^Log:$';then
			REACHED_LOG=1
			continue
		fi
		if [ ${REACHED_LOG} -eq 1 ];then
			LOG_MESSAGE=${line}
			REACHED_LOG=2
			continue
		fi
		if [ ${REACHED_LOG} -eq 2 ];then
			LOG_MESSAGE="${LOG_MESSAGE}
${line}"
			continue
		fi
	done

	cat /dev/null > commit-message
	echo "${LOG_MESSAGE}" |head -n1 >commit-message
	echo >>commit-message
	echo "${LOG_MESSAGE}" >>commit-message
	echo >>commit-message
	echo "${DATE}" >>commit-message
	echo "${AUTHOR}" >>commit-message
	echo "Patchset: ${PATCHSET}" >>commit-message

	git commit --allow-empty-message -v -e -F commit-message .
	rm -f commit-message

	echo -n "successfully applied patchset #${PATCHSET}. press enter to continue with the next file."; read
	PATCHSET=$(( PATCHSET + 1 ))
done
