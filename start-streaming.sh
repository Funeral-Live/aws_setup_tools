#!/bin/bash

# gst-launch-1.0 rtspsrc location=rtsp://root:pass@${1}/axis-media/media.amp latency=150 ! queue ! rtph264depay ! queue ! h264parse ! flvmux streamable=true name=mux ! rtmpsink location="${2}" audiotestsrc ! voaacenc bitrate=128000 ! mux.

# gst-launch rtspsrc location=rtsp://root:pass@${1}/axis-media/media.amp latency=150 ! queue ! rtph264depay ! queue ! h264parse ! flvmux streamable=true name=mux ! rtmpsink location="${2}"


if [ ${3} == "true" ]
then
  gst-launch-1.0 rtspsrc location=rtsp://${1}:554/ch01 latency=150 ! queue ! rtph264depay ! queue ! h264parse ! flvmux streamable=true name=mux ! rtmpsink location="${2}" audiotestsrc wave=4 ! voaacenc bitrate=12800 ! mux.
else
  gst-launch-1.0 rtspsrc location=rtsp://root:pass@${1}/axis-media/media.amp latency=150 ! queue ! rtph264depay ! queue ! h264parse ! flvmux streamable=true name=mux ! rtmpsink location="${2}" audiotestsrc wave=4 ! voaacenc bitrate=12800 ! mux.
fi

