#!/bin/sh

test_description='exercise basic multi-pack bitmap functionality (.rev files)'

. ./test-lib.sh
. "${TEST_DIRECTORY}/lib-bitmap.sh"

# We'll be writing our own midx and bitmaps, so avoid getting confused by the
# automatic ones.
GIT_TEST_MULTI_PACK_INDEX=0
GIT_TEST_MULTI_PACK_INDEX_WRITE_BITMAP=0

# Unlike t5326, this test exercise multi-pack bitmap functionality where the
# object order is stored in a separate .rev file.
GIT_TEST_MIDX_WRITE_REV=1
GIT_TEST_MIDX_READ_RIDX=0
export GIT_TEST_MIDX_WRITE_REV
export GIT_TEST_MIDX_READ_RIDX

midx_bitmap_core rev
midx_bitmap_partial_tests rev

test_expect_success 'reinitialize the repository with lookup table enabled' '
    rm -fr * .git &&
    git init &&
    git config pack.writeBitmapLookupTable true
'

midx_bitmap_core rev
midx_bitmap_partial_tests rev

test_done
