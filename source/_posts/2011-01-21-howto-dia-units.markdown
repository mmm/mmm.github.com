---
layout: post
title: units in dia
categories: howtos
comments: true
---

Ok, dia is totally screwed up with units... 
here's how to make it work well.

open dia

File -> Preferences 

    User Interface
      length unit: Centimeter
      Font-size unit: Point
    Diagram Defaults
      Portrait
      Paper type: Letter
      Connection Points:
        Visible
        Snap to object
    View Defaults
      Width: 800
      Height: 600
      Magnify: 100
      Page breaks:
        uncheck "Visible"
      Antialias:
        uncheck "view antialiased"
    Grid Lines
      Visible
      Snap to
      uncheck Dynamic grid resizing
      X Size: 1.0
      Y Size: 1.0
      Lines per major line: 5

on the diagram window... File->Page Setup

    Paper Size: Letter
    orientation again portrait
    Margins
      2.54cm all around
    Scale: 100.0

View->Hide Rulers

This results in a window with 100x100pixel gridlines
(when exported as png w/ or w/o alpha)

results in 5cmx5cm grids when exported directly to pdf


