---
layout: post
title: "Screencasts on Ubuntu using ffmpeg"
date: 2020-07-29
comments: true
categories: [mids, ubuntu]
---


We developed these scripts for recording the screencast components of the class
we co-developed a couple of years ago.

In this post I describe the capture setup we use to create professional quality
screencasts using an Ubuntu Linux desktop. This just describes the recording
process itself. We discuss the overall screencast development process and
editing in separate posts.

<!--more-->

## Contents

- Overview
- Desktop
- Slides
- Terminal
- Camera
- Audio
- Putting it all together


## Overview

The screencasts recorded for the class encompassed both high-level conceptual
material as well as detailed examples or tutorials.

To do that we really wanted to have the flexibility of showing both slides as
well as terminal or web interactions at the same time. We also figured it's a
good idea to have the ability to overlay a talking head when there's not much
other detailed interaction going on, so we also wanted to be sure we captured
camera footage during the recordings as well.

This setup is designed to capture raw footage of all of those channels at once.
We looked around, but couldn't find any off-the-shelf tools that really met our
needs for this.  It turns out this is actually pretty easy to accomplish just
using `ffmpeg` directly from a script.


## Desktop

Note the desktop setup:

- Ubuntu desktop with three monitors set up within a single X session

- Each desktop is `1920x1080`, so the total big desktop size is `3x1920` pixels
  wide and 1080 pixels tall

- Terminals/Browsers run on the left-hand monitor

- Slides are full-screen on the center monitor

- Webcam lives on top of the left monitor so we're looking roughly towards the
  camera when going through a detailed example

- Sound is coming from a lavalier mic plugged into a USB audio interface made
  available via standard Linux alsa devices

- I use the right-hand monitor to hold terminal windows to start/stop these scripts,
  but nothing from there is recorded

Below, we'll go through each of the different capture channels used 
and then wrap it all up with a bow into a single script that follows
the `screencasts -> shots -> takes` file organization that we used to keep
track of all of this.


## Slides

To capture a stream of slides, we're using the `x11grab` ffmpeg interface. This
is designed to just sample what the X server sees every so often (`$framerate`)
and then encode and save that as a video stream.

The tricky part is creating a command to record the correct monitor for slides.
Since the middle monitor is running slides, we tell `ffmpeg` to capture a
single monitor's `1920x1080` worth of screen but _start_ that from the geometry
offset `+1920,0`... the top of the middle monitor.

The command 

```
ffmpeg \
  -hide_banner -nostats -loglevel warning \
  -f x11grab -r $framerate -s hd1080 -i :0.0+1920,0 \
  -vcodec libx264 \
  -preset ultrafast \
  $output_dir/slides.mkv > $output_dir/slides.log 2>&1
```

gets wrapped in a bash function to capture slides:

```
capture_slides() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r $framerate -s hd1080 -i :0.0+1920,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/slides.mkv > $output_dir/slides.log 2>&1
  echo "slides done"
}
```

This saves to the files `slides.mkv` and `slides.log`.


## Terminal

We'll use `x11grab` to record the left-hand monitor as well. The offset here is
just the top of the left-hand monitor, so `+0,0` in X geometry speak:

```
capture_terminal() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r $framerate -s hd1080 -i :0.0+0,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/terminal.mkv > $output_dir/terminal.log 2>&1
  echo "terminal done"
}
```

This saves to the files `terminal.mkv` and `terminal.log`.


## Camera

To capture the stream from the webcam, we're relying heavily on the fact that
the 
[Logitech HD Pro Webcam C920](https://www.amazon.com/gp/product/B006JH8T3S/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
does hardware h264 encoding on the fly and we're just tapping into that using
ffmpeg's `v4l2` interface to simply `copy` the video stream out to a file.

I also had some problems understanding the timestamps that the camera's
hardware encoder used, so I include the set of `ffmpeg` args that fixed that.
YMMV depending on your camera.

Probably the most important thing to recognize is that the capture relied on
the hardware encoding.  If we were getting raw video and having to encode on
the fly, then the desktop's computational capabilities my come more into play.
This usually results is limiting the framerate you can actually record.

Here's the function to capture the camera footage:

```
capture_webcam() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f v4l2 -framerate $framerate -input_format h264 -video_size hd1080 -ts mono2abs -i /dev/video0 \
    -c copy -copyts -start_at_zero \
    $output_dir/webcam.mkv > $output_dir/webcam.log 2>&1
  echo "webcam done"
}
```

This saves to `webcam.mkv` and `webcam.log`.


## Audio

Audio is coming in through a 
[TASCAM US-2x2](https://www.amazon.com/gp/product/B00MIXF2RS/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
USB-audio interface, where I have a 
[lavalier mic](https://www.amazon.com/gp/product/B01GSVQN6Y/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
plugged in.  This "just worked" through the `alsa` interface for `ffmpeg` so we
just need to copy the raw audio stream from the device:

```
capture_audio() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f alsa -i default \
    -c copy -copyts -start_at_zero \
    $output_dir/audio.wav > $output_dir/audio.log 2>&1
  echo "audio done"
}
```

which saves `audio.wav` and `audio.log`.


## Putting this all together

So all of the above functions get rolled up into a single script named
`capture`.

This script kicks off the `ffmpeg` recordings at roughly the same
time and saves all the output to

```
output_dir="screencasts/${scene_name}/shot-${shot_number}/take-${timestamp}"
```

where the variables in there either are defaults (like the shot number) or are
specified as arguments to the script.  I typically use it like

```
cd /opt/screencasts/introducing-spark-streaming
capture
```

which kicks off the recording and streams outputs to files such as

```
- shot-010
  - take-2018-03-12-165010
    - audio.log
    - audio.wav
    - slides.log
    - slides.mkv
    - terminal.log
    - terminal.mkv
    - webcam.log
    - webcam.mkv
```

This folder structure lets us keep things nice and tidy for editing.

So here's the final script:

```
#!/bin/bash

set -o errexit -o nounset -o pipefail

usage() {
	echo "Usage: $0 <scene_name> [<shot_number>]
    where:
      <scene_name> is something like intro-what-is-data-eng
      <shot_number> optional, default is 010"
}
(( $# < 1 )) && usage && exit 1
scene_name=$1
shot_number=${2:-010}

timestamp=`date +%Y-%m-%d-%H%M%S`
output_dir="screencasts/${scene_name}/shot-${shot_number}/take-${timestamp}"
framerate=30

capture_slides() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r $framerate -s hd1080 -i :0.0+1920,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/slides.mkv > $output_dir/slides.log 2>&1
  echo "slides done"
}

capture_terminal() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f x11grab -r $framerate -s hd1080 -i :0.0+0,0 \
    -vcodec libx264 \
    -preset ultrafast \
    $output_dir/terminal.mkv > $output_dir/terminal.log 2>&1
  echo "terminal done"
}

capture_audio() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f alsa -i default \
    -c copy -copyts -start_at_zero \
    $output_dir/audio.wav > $output_dir/audio.log 2>&1
  echo "audio done"
}

capture_webcam() {
  local output_dir=$1
  ~/bin/ffmpeg \
    -hide_banner -nostats -loglevel warning \
    -f v4l2 -framerate $framerate -input_format h264 -video_size hd1080 -ts mono2abs -i /dev/video0 \
    -c copy -copyts -start_at_zero \
    $output_dir/webcam.mkv > $output_dir/webcam.log 2>&1
  echo "webcam done"
}

##################

echo "starting ${scene_name}/shot-${shot_number}/take-${timestamp}"

mkdir -p $output_dir

echo "capturing slides"
capture_slides $output_dir &

echo "capturing terminal"
capture_terminal $output_dir &

echo "capturing webcam"
capture_webcam $output_dir &

echo "capturing audio"
capture_audio $output_dir &

for job in `jobs -p`; do
  wait $job
done

echo "done"
```

Note that each function is run in the background so they're effectively kicked
off in parallel.
