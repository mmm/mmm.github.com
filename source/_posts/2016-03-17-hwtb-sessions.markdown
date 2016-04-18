---
layout: post
title: "Identifying User Activity from Streams of Raw Events"
date: 2016-03-17 12:08
comments: true
categories: [data-engineering, spark, hadoop, devops]
---


I had a chance to speak at an online conference last weekend,
[Hadoop With The Best](http://hadoop.withthebest.com/).
I had fun sharing one of my total passions... data pipelines!
In particular, some techniques for catching raw user events,
acting on those events and understanding user activity from 
the sessionization of such events.

<!--more-->

[SVDS](svds.com) is a boutique data science consulting firm.  We help folks
with their hardest Data Strategy, Data Science, and/or Data Engineering
problems.  In this role, we're in a unique position to solve different
kinds of problems across various industries... and we really start
to see commonalities across solutions.

This talk is about some common data pipeline patterns used
across various kinds of systems across various industries.
Key Takeaways include:

- what's needed to understand user activity
- pipeline architectures that support this analysis

Along the way, I'll point out commonalities across business verticals and we'll
see how volume and latency requirements, unsurprisingly, turn out to be the
biggest differentiators.


## Agenda

- Ingest Events
- Take Action
- Recognize Activity


## Ingest Events

What are events and how do we catch them?

There are device events

- location
- environment
- telemetry
- presence
- status (disk is full)
- ...

e.g.,

    {
      "time_utc": "1457741907.959400112",
      "device_id": "c361-445b-b2f6-27f2eecfc217",
      "event_type": "environmental_info",
      "degrees_fahrenheit": "72",
      ...
    }


and user or HCI events

- login
- checkout
- add friend
- ...

e.g.,

    {
      "time_utc": "1457741907.959400112",
      "user_id": "688b60d1-c361-445b-b2f6-27f2eecfc217",
      "event_type": "login",
      ...
    }

We'll mostly focus on user events.

User events can be "flat"

    {
      "time_utc": "1457741907.959400112",
      "user_id": "688b60d1-c361-445b-b2f6-27f2eecfc217",
      "event_type": "button_pressed",
      "button_type": "one-click purchase",
      "item_sku": "1 23456 78999 9",
      "item_description": "Tony's Run-flat Tire",
      "item_unit_price": ...
      ...
    }

or not

    {
      "time_utc": "1457741907.959400112",
      "user_id": "688b60d1-c361-445b-b2f6-27f2eecfc217",
      "event_type": "button_pressed",
      "event_details": {
        "button_type": "one-click purchase",
        "puchased_items": [
          {
            "sku": "1 23456 78999 9",
            "description": "Tony's Run-flat Tire",
            "unit_price": ...
            ...
          },
        ],
      },
      ...
    }

There are great formats and tools, but the state of the
art is pretty shoddy... adaptation/munging is often required

### Stages of an ingestion pipeline:

The primary goal of an ingestion pipeline is to... ingest events.

<a href="/images/event-ingestion-without-streaming.svg">
<img src="/images/event-ingestion-without-streaming.svg"  width="720px" />
</a>

<a href="/images/event-ingestion-without-streaming-with-filename.svg">
<img src="/images/event-ingestion-without-streaming-with-filename.svg" width="720px" />
</a>

Get the events as raw as possible as far back as possible in a format that's 
amenable to fast queries.  Remember, the power of the query side.

Tenants to keep in mind here... build a pipeline that's immutable, lazy,
simple/composable, and testable.

<a href="/images/events-without-streaming-question.svg">
<img src="/images/events-without-streaming-question.svg" width="720px" />
</a>

<a href="/images/streaming-bare.svg">
<img src="/images/streaming-bare.svg" width="720px" />
</a>

<a href="/images/streaming-events-at-scale.svg">
<img src="/images/streaming-events-at-scale.svg" width="720px" />
</a>

<a href="/images/streaming-events-at-scale-with-partitioning.svg">
<img src="/images/streaming-events-at-scale-with-partitioning.svg" width="720px" />
</a>

Note, we're assuming for now that events have a well-defined type... they generally don't.


## Take Action 

### What kind of actions?

- Notifications
- Decorations
- Routing / Gating
- Counting
- ...

### When to take action?

- "batch"
- "real-time"

<a href="/images/streaming-bare.svg">
<img src="/images/streaming-bare.svg" width="720px" />
</a>

if latency is ok, it might be good enough to take action from the query side

try that first

<a href="/images/streaming-simple.svg">
<img src="/images/streaming-simple.svg" width="720px" />
</a>

if lower latency is required, act directly from the streaming layer

<a href="/images/streaming-with-notify-queues.svg">
<img src="/images/streaming-with-notify-queues.svg" width="720px" />
</a>

<a href="/images/streaming-two-layers.svg">
<img src="/images/streaming-two-layers.svg" width="720px" />
</a>


---

## Recognize Activity 

What's user activity?  Usually it's a *Sequence of one or more events*
associated with a user.  From an infrastructure standpoint, the key distinction
is that activity is constructed from a sequence of user events... _that don't
all fit within a single window of stream processing_.  This can either be
because there are too many of them or because they're spread out over too long
a period of time.

Another way to think of this is that event context matters.  In order to
recognize activity as such, you often need to capture or create user context
(let's call it "state") in such a way that it's easily read by (and possibly
updated from) processing in-stream.

We add hbase to our standard stack, and use it to store state
<a href="/images/classifying-with-state.svg">
<img src="/images/classifying-with-state.svg" width="720px" />
</a>

which is then accessible from either stream or batch processing.  HBase is
attractive as a fast key-value store.  Several other key-value stores could
work here... I'll often start using one simply because it's easier to
deploy/manage at first.  Then refine the choice of tool once more precise
performance requirements of the state store have emerged from use.

It's important to note that you want fast key-based reads and writes.
Full-table scans of columns are pretty much verboten in this setup.  They're
simply too slow for value from stream.

The usual approach is to update state in batch.  My favorite example when first
talking to folks about this approach is to consider a user's credit score.
Events coming into the system are routed in stream based on the associated
user's credit score.

The stream system can simply (hopefully quickly) look that up in HBase keyed
on a user id of some sort
<a href="/images/hbase-state-credit-score.svg">
<img src="/images/hbase-state-credit-score.svg" width="720px" />
</a>
The credit score is some number calculated by scanning across all a user's
events over the years.  It's a big, long-running, expensive computation.  Do
that continuously in batch... just update HBase as you go.  If you do that,
then you make that information available for decisions in stream.

Note that this is effectively a way to base fast-path decisions on
information learned from slow-path computation.  A way for the system to
quite literally _learn from the past_  :-)

Another example of this is tracking a package.  The events involved are the
various independent scans the package undergoes throughout its journey.

For "state" you might just want to keep an abbreviated version of the raw
history of each package
<a href="/images/hbase-state-tracking-package.svg">
<img src="/images/hbase-state-tracking-package.svg" width="720px" />
</a>
or just some derived notion of its state
<a href="/images/hbase-state-tracking-package-derived.svg">
<img src="/images/hbase-state-tracking-package-derived.svg" width="720px" />
</a>
those derived notions of state are tough to define from a single scan in a
warehouse somewhere... but make perfect sense when viewed in the context of the
entire package history.


---

## A Nod to Best Practices

### The Power of the Query Side
Query-side tools are fast -- use them effectively!

### Infrastructure Aspirations
When building datascience pipelines, these paradigms 
help you stay flexible and scalable

- immutable
- lazy
- atomic
    - simple
    - composable
    - testable

### Automate All of the Things
DevOps is your friend

### Test All of the Things
TDD/BDD is your friend

### Failure is a First Class Citizen
Fail fast, early, often

---

## Wrap-up

- Ingest Events
- Take Action
- Recognize Activity

<a href="/images/classifying-with-state.svg">
<img src="/images/classifying-with-state.svg"  width="720px" />
</a>


## The Talk Itself

It was a somewhat challenging presentation format.  I presented a live video
feed solo while the audience was watching live and had the ability to send
questions in via chat... no audio from the audience.  Somewhat reminiscent of
IRC-based presentations we used to do in Ubuntu community events... but with
video.

The moderator asked the audience to queue questions up until the end, but as
anyone who's been in a classroom with me knows, I welcome / live for
interruptions :-) In this case, I could easily see the chat window as I
presented so asking-questions-along-the-way is supported on that presentation
platform.  I'd definitely ask for that in the future.

I do prefer the fireside chat nature of adding one or two more folks into the
feed... kinda like on-the-air hangouts... where the speaker can get audible
feedback from some folks.  Overall though this was a great experience and folks
asked interesting questions at the end.  I'm not sure how it'll be published,
but questions had to be done in a second section as I dropped connectivity
right at the end of the speaking session.

Slides are available
[here](http://archive.markmims.com/box/talks/2016-03-12-hwtb-sessions/slides.html),
and you can get the video straight from the [hadoop with the
best](hadoop.with-the-best.com) site.  Note that the slides are
[reveal.js](https://github.com/hakimel/reveal.js/) and I make heavy use of
two-dimensional navigation.  Slides advance downwards, topics advance to the
right.

