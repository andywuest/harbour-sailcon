#!/bin/bash

cd typescript/html
tsc -m none --alwaysStrict DukeConServer.ts --out ../../qml/pages/utils2.js
cd ..
cd ..

