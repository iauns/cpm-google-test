cpm-google-test
===============

[![Build Status](https://travis-ci.org/iauns/cpm-google-test.png)](https://travis-ci.org/iauns/cpm-google-test)

CPM external for [google test](http://code.google.com/p/googletest/).

Use
---

```c++
#include "gtest/gtest.h"
```

Linux Caveat
------------
You will need to add '-pthread' to the end your `target_link_libraries` call on
some linux platforms. Like so:

```
if (UNIX)
  if (NOT APPLE)
    set(PTHREADS "-pthread")
  endif()
endif()

add_executable(google_test_test ${Sources})
target_link_libraries(google_test_test ${CPM_LIBRARIES} ${PTHREADS})
```

