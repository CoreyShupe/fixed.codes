#!/bin/bash

elm make src/Main.elm --output assets/elm_entry.js
./local-proxy
