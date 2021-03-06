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

{% youtube 7geRGzrIXRI %}

[SVDS](svds.com) is a boutique data science consulting firm.  We help folks
with their hardest Data Strategy, Data Science, and/or Data Engineering
problems.  In this role, we're in a unique position to solve different
kinds of problems across various industries... and start to recognize
the patterns of solution that emerge.  That's what I'd like to share.

This talk is about some common data pipeline patterns used
across various kinds of systems across various industries.
Key Takeaways include:

- what's needed to understand user activity
- pipeline architectures that support this analysis

Along the way, I point out commonalities across business verticals and we see
how volume and latency requirements, unsurprisingly, turn out to be the biggest
differentiators in solution.


## Agenda

- Ingest Events
- Take Action
- Recognize Activity


## Ingest Events

The primary goal of an ingestion pipeline is to... ingest events.  All other
considerations are secondary.  We walk through an example pipeline and discuss
how that architecture changes as we adjust scaling up to handle billions of
events a day.  We'll note along the way how general concepts of immutability
and lazy evaluation can have large ramifications on data ingestion pipeline
architecture.

I start out covering typical classes of and types of events, some common event
fields, and various ways that events are represented.  These vary _greatly_
across current and legacy systems, and you should always expect that munging
will be involved as you're working to ingest events from various data sources
over time.

For our sessionization examples, we're interested in user events such as
`login`, `checkout`, `add friend`, etc.

These user events can be "flat"

```
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
```

or have some structure


```
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
```

and often both formats get used in the same systems in the wild so
you have to intelligently detect or classify events rather than 
just making blatant assumptions about them.  And yes, that _is_ 
expensive... but it's surprisingly common.


### Ingestion Pipelines

So what do basic ingestion pipelines usually look like?

Tenants to keep in mind here... build a pipeline that's immutable, lazy,
simple/composable, and testable.  I come back to these often throughout
the talk.

With our stated goal
of ingesting events, it should look pretty simple right?  Something along the
lines of
<a href="/images/event-ingestion-without-streaming-with-filename.svg">
<img src="/images/event-ingestion-without-streaming-with-filename.svg" width="720px" />
</a>

I introduce the "Power of the Query Side"... query-side tools are fast
nowadays.  Tools such as Impala have really won me over.  The Ingest pipeline
needs to get the events as raw as possible as far back as possible in a format
that's amenable to fast queries.  Let's state that again... it's important.
The pipeline's core job is to get events that are as raw as possible (immutable
processing pipeline) as far back into the system as possible (lazily evaluated
analysis) before any expensive computation is done.  Modern query-side tools
support these paradigms quite well.  Better performance is obtained when events
land in query-optimized formats and are grouped into query-optimized files and
partitions where possible
<a href="/images/event-ingestion-without-streaming-with-filename.svg">
<img src="/images/event-ingestion-without-streaming-with-filename.svg" width="720px" />
</a>

That's simple enough and seems pretty straightforward in theory.  In practice
you can ingest events straight into files in hdfs only up to a certain scale
and degree of event complexity.

As scale increases, an ingestion pipeline has to become effectively a dynamic
impedance matching network.  It's the funnel that's catching events from what
can be a highly distributed, large number of data sources and trying to slam
all these events into a relatively small number of filesystem datanodes.

What can we we do to match those separate source sizes from target sizes?
<a href="/images/events-without-streaming-question.svg">
<img src="/images/events-without-streaming-question.svg" width="720px" />
</a>
use Spark!  :-)

No, but seriously, add a streaming solution in-between (I do like Spark
Streaming here)
<a href="/images/streaming-bare.svg">
<img src="/images/streaming-bare.svg" width="720px" />
</a>
and use Kafka to decouple all the bits
<a href="/images/streaming-events-at-scale.svg">
<img src="/images/streaming-events-at-scale.svg" width="720px" />
</a>
in such a way that your datasources on the left, and your datanodes on the
right can scale independently!  And independently from any stream computation
infrastructure you might need for in-stream decisions in the future.  I go
through that in a little more detail in the talk itself.

Impedance or size mismatches between data sources and data storage are really
only one half of the story.  Note that another culprit, _event complexity_, can
limit ingest throughput for a number of reasons.  A common example of where
this happens is when event "types" are either poorly defined or are changing so
much they're hard to identify.  As event complexity increases, so does the
logic you use to group or partition the events so they're fast to query.  In
practice this quickly grows from simple logic to full-blown event
classification algorithms.  Often those classification algorithms have to learn
from the body of events that've already landed.  You're making decisions on
events in front of you based on all the events you've ever seen.  I'll bump any
further discussion of that until we talk more about state in the "Recognize
Activity" section later.

Ingest pipelines can get complicated as you try to scale in size and
complexity... expect it!... plan for it!  The best way is to do this is to
build or use a toolchain that can let you add a streaming and queueing solution
without a lot of rearchitecture or downtime.  Folks often don't try to solve
this problem until it's already painful in production!  There're great ways
to solve this in general.  My current fav atm uses a hybrid combination of
Terraform, Consul, Ansible, and ClouderaManager/Ambari.

Note also that we haven't talked about any real-time processing or low-latency
business requirements here at all.  The need for a stream processing solution
arises when we're _just_ trying to catch events at scale.


---

## Take Action 

Catching events within the system is an interesting challenge all by itself.
However, just efficiently and faithfully capturing events isn't the end of the
story.

<a href="/images/streaming-bare.svg">
<img src="/images/streaming-bare.svg" width="720px" />
</a>

That's sorta boring if we're not taking _action_ on events as we catch
them.

Actions such as 

- Notifications
- Decorations
- Routing / Gating
- Counting
- ...

can be taken in either "batch" or "real-time" modes.

<a href="/images/streaming-simple.svg">
<img src="/images/streaming-simple.svg" width="720px" />
</a>

Unfortunately, folks have all sorts of meanings for these terms.  Let's clear
that up and be a little more precise...

For every action you intend to take, and really every data product of your
pipeline, you need to determine the latency requirements.  What is the
timeliness of that resulting action?  So how soon after either a.) an event was
generated, or b.) an event was seen within the system will that resulting
action be valid?  The answers might surprise you.

Latency requirements let you make a first-pass attempt at specifying the
_execution context_ of each action.  There are two separate execution contexts we
talk about here... _batch_ and _stream_.

- batch.  Asynchronous jobs that are potentially run against the entire body of
  events and event histories.  These can be highly complex, computationally
  expensive tasks that might involve a large amount of data from various
  sources.  The implementations of these jobs can involve Spark or Hadoop
  map-reduce code, Cascading-style frameworks, or even sql-based analysis via
  Impala, Hive, or SparkSQL.

- stream.  Jobs that are run against either an individual event or a small
  window of events.  These are typically simple, low-computation jobs that
  don't require context or information from other events.  These are typically
  implemented using Spark-streaming or Storm code.


When I say "real-time" in this talk, I mean that the action will be taken from
within the stream execution context.

It's important to realize that not all actions require "real-time" latency.
There are plenty of actions that are perfectly valid even if they're operating
on "stale" day-old, hour-old, 15min-old data.  Of course, this sensitivity to
latency varies greatly by action, domain, and industry.  Also, how stale stream
-vs- batch events are depend of the actual performance characteristics of your
ingestion pipeline under load.  Measure all the things!

An approach I particularly like is to initially act from a batch context.
There's generally less development effort, more computational resources, more
robustness, more flexibility, and more forgiveness involved when you're working
in a batch execution context.  You're less likely to interrupt or congest your
ingestion pipeline.

Once you have basic actions working from the batch layer, then do some
profiling and identify which of the actions you're working with really require
less stale data.  _Selectively_ bring those actions or analyses forward.  Tools
such as Spark can help tremendously with this.  It's not all fully baked yet,
but there are ways to write spark code where the same business logic code can
be optionally bound in either stream or batch execution contexts.  You can move
code around based on pipeline requirements and performance!

In practice, a good deal of architecting such a pipeline is all about
preserving or protecting your stream ingestion and decision-making capabilities
for when you really need them.

A real system often involves additionally protecting and decoupling your stream
processing from making any service API calls (sending emails for example) by
adding kafka queues for things like outbound notifications _downstream_ of
ingestion
<a href="/images/streaming-with-notify-queues.svg">
<img src="/images/streaming-with-notify-queues.svg" width="720px" />
</a>
as well as isolating your streaming system from writes to hdfs using 
the same trick (as we saw above)
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

## Wrap-up

I eventually come back to our agenda:

- Ingest Events
- Take Action
- Recognize Activity

Along the way we've done a nod to some data-plumbing best practices... such as

#### The Power of the Query Side
Query-side tools are fast -- use them effectively!

#### Infrastructure Aspirations
A datascience pipeline is

- immutable
- lazy
- atomic
    - simple
    - composable
    - testable

When building datascience pipelines, these paradigms 
help you stay flexible and scalable

#### Automate All of the Things
DevOps is your friend.  We're using an interesting pushbutton stack that'll be
the topic of another blog post :-)

#### Test All of the Things
TDD/BDD is your friend.  Again, I'll add another post on "Sanity-Driven Data
Science" which is my take on TDD/BDD as applied to datascience pipelines.

#### Failure is a First Class Citizen
Fail fast, early, often... along with the obligatory reference to the Netflix
Simian Army.


---

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

Update: this post has be perdied-up (thanks Meg!) and reposted as part of our
[svds blog](http://www.svds.com/building-pipelines-understand-user-behavior/).

