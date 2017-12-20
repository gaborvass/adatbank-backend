#!/usr/bin/env bash

swift package -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib generate-xcodeproj
