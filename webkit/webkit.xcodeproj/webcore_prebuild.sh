#!/bin/sh

# Copyright (c) 2008 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex
GENERATED_DIR="${CONFIGURATION_TEMP_DIR}/generated"
mkdir -p "${GENERATED_DIR}"

# Generate the webkit version header
mkdir -p "${GENERATED_DIR}/include/v8/new"
python build/webkit_version.py \
       ../third_party/WebKit/WebCore/Configurations/Version.xcconfig \
       "${GENERATED_DIR}/include/v8/new"

# Only use new the file if it's different from the existing file (if any),
# preserving the existing file's timestamp when there are no changes.  This
# minimizes unnecessary build activity for a no-change build.
if ! diff -q "${GENERATED_DIR}/include/v8/new/webkit_version.h" \
             "${GENERATED_DIR}/include/v8/webkit_version.h" >& /dev/null ; then
  mv "${GENERATED_DIR}/include/v8/new/webkit_version.h" \
     "${GENERATED_DIR}/include/v8/webkit_version.h"
else
  rm "${GENERATED_DIR}/include/v8/new/webkit_version.h"
fi

rmdir "${GENERATED_DIR}/include/v8/new"

# TODO(mmentovai): Am I still needed?
ln -sfh "${SRCROOT}/../third_party/WebKit/WebCore" WebCore

# TODO(mmentovai): If I'm still needed, can I move to jsbindings_prebuild.sh?
cd "${GENERATED_DIR}/DerivedSources/v8"
mkdir -p ForwardingHeaders/loader
ln -sfh "${SRCROOT}/../third_party/WebKit/WebCore/loader" \
        ForwardingHeaders/loader/WebCore
