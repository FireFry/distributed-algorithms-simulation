#!/bin/sh
mkdir -p target/
rm -f target/concat.coffee
coffeescript-concat -I coffeescript/ -o target/concat.coffee
coffee target/concat.coffee
