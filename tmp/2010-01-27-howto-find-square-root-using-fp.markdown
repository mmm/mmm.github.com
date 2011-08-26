---
layout:post
title: $i
tags: ["howto"]
---



Heron of Alexandria... method of successive averaging

how to approx square root of a number x :
  - guess, g
  - improve guess by averaging that guess g with  x/g
  - keep improving the guess until it's good enough
  - use 1 as an initial guess


------


f: x,y -> average(y,x/y)

fixed point of this function is sqrt(x)


method for finding a fp of a function f:
  - guess y
  - apply f over and over until the result doesn't change very much


