#!/bin/sh

test_description='reset --hard unmerged'

TEST_PASSES_SANITIZE_LEAK=true
. ./test-lib.sh

test_expect_success setup '

	mkdir before later &&
	>before/1 &&
	>before/2 &&
	>hello &&
	>later/3 &&
	git add before hello later &&
	git commit -m world &&

	H=$(git rev-parse :hello) &&
	git rm --cached hello &&
	echo "100644 $H 2	hello" | git update-index --index-info &&

	rm -f hello &&
	mkdir -p hello &&
	>hello/world &&
	test "$(git ls-files -o)" = hello/world

'

test_expect_success 'reset --hard should restore unmerged ones' '

	git reset --hard &&
	git ls-files --error-unmatch before/1 before/2 hello later/3 &&
	test -f hello

'

test_expect_success 'reset --hard did not corrupt index or cache-tree' '

	T=$(git write-tree) &&
	rm -f .git/index &&
	git add before hello later &&
	U=$(git write-tree) &&
	test "$T" = "$U"

'

test_expect_failure CASE_INSENSITIVE_FS 'reset --hard handles index-only case-insensitive duplicate' '
	test_commit "initial" file1 "initial commit with file1" initial &&
	file1blob=$(git rev-parse :file1) &&
	git update-index --add --cacheinfo 100644,$file1blob,File1 &&

	# reset --hard accidentally leaves the working tree with a deleted file.
	git reset --hard &&
	git status --porcelain -uno >wt_changes_remaining &&
	test_must_be_empty wt_changes_remaining
'

test_done
