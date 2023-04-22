#!/bin/sh


LOCAL_DIR="$(pwd)"
REMOTE_DIR="${LOCAL_DIR}/../openbsd/src/bin/ksh/"
IFS='
'

cd "${LOCAL_DIR}"

if [ -z "$1" ];then
	COMMITID=$(git show --no-patch --pretty='%b' HEAD |grep -E -e '^Original commit id: ' |cut -d' ' -f4)
	echo "Press enter to start after commit id: ${COMMITID} or quit and tell me which commit id to start with as the first parameter"; read
else
	COMMITID=$1
fi

[ -z "${COMMITID}" ] && { echo 'No starting commit id detected or specified...'; exit 1; }

COMMITS=$(cd "${REMOTE_DIR}"; git log --reverse --pretty=oneline "${COMMITID}".. "${REMOTE_DIR}")

for commit in ${COMMITS};do
	id=$(echo "${commit}" |cut -d' ' -f1)
	comment=$(echo "${commit}" |cut -d' ' -f2-)
	echo "===> ${id} (${comment})"

	echo "Dry run:"
	( cd "${REMOTE_DIR}"; git show "${id}" . ) |patch -p3 --dry-run

	echo -n "Apply ${id}? (y/n) [y] "; read
	if [ "${REPLY}" != 'n' -a "${REPLY}" != 'N' ];then
		rm -f *.rej
		( cd "${REMOTE_DIR}"; git show "${id}" . ) |patch --no-backup-if-mismatch -p3 || { ls -l *.rej; echo -n "failed to apply ${diff}. escape to shell, fix rejections, then get back here and press enter."; read; }
	fi

	echo "Build test:"
	make || { echo "the test build has failed. escape to shell, fix it, then get back here and press enter."; read; }

	# generate the commit message
	( cd "${REMOTE_DIR}"; git show --no-patch --pretty=format:"%<(50,trunc)%s%n%nDate: %ai%nAuthor: %an <%ae>%nOriginal commit id: %H%n%n%s%n%n%b" "${id}" ) >commit-message

	git commit --allow-empty-message -v -e -F commit-message .
	rm -f commit-message

	echo "successfully applied commit id ${id}."
	echo -n "press enter to continue with the next commit id."; read
done
