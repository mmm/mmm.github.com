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

SVDS is a boutique...

    we're in a unique position

    solve problems across industries

    recognize patterns along the way


    ## Key Takeaways
    - what's needed to understand user activity
    - pipeline architectures that support this analysis

    <div class="notes">
    Along the way, we'll see:

    - commonalities across business verticals

    - differences due to scale
    </div>


    ## Agenda { data-background="images/watch-faded.png" }

    - Ingest Events
    - Take Action
    - Recognize Activity

    <div class="notes">
    we dive into pipeline architectures along the way
    </div>


    ## Background
    <div class="notes">
    Some general guidelines to keep in mind
    </div>

    ## The Power of the Query Side
    <div class="notes">
    Query-side tools are fast!

    use them
    </div>

    ## Infrastructure Aspirations
    - immutable
    - lazy
    - ...
    <div class="notes">
    When building datascience pipelines, these paradigms 
    help you stay flexible and scalable
    </div>


    ## Ingest Events
    <div class="notes">
    What are events and how do we catch them?
    </div>

    ## Device Events
    - location
    - environment
    - telemetry
    - presence
    - status (disk is full)
    - ...
    <div class="notes">
    </div>

    ## User Events
    - login
    - checkout
    - add friend
    - ...
    <div class="notes">
    </div>

    ## Device Event
    <pre><code>
    {
      "time_utc": "1457741907.959400112",
      "device_id": "c361-445b-b2f6-27f2eecfc217",
      "event_type": "environmental_info",
      "degrees_fahrenheit": "72",
      ...
    }
    </code></pre>

    <div class="notes">
    there are device events
    </div>

    ## User Event
    <pre><code>
    {
      "time_utc": "1457741907.959400112",
      "user_id": "688b60d1-c361-445b-b2f6-27f2eecfc217",
      "event_type": "login",
      ...
    }
    </code></pre>
    <div class="notes">
    we'll mostly focus on HCI events.

    they can be simple...
    </div>

    ## Flat User Event
    <pre><code>
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
    </code></pre>
    <div class="notes">
    they can be more complex...
    </div>

    ## Complex User Event
    <pre><code>
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
    </code></pre>
    <div class="notes">
    they can be downright ugly...

    There are great formats and tools, but the state of the
    art is pretty shoddy... adaptation/munging is often required
    </div>

    ## { data-background="images/event-ingestion-without-streaming.svg" }
    <div class="notes">
    The Power of the Query Side

    Tenants to live by... immutable, lazy, simple/composable, testable
    </div>

    ## { data-background="images/event-ingestion-without-streaming-with-filename.svg" }

    ## { data-background="images/events-without-streaming-question.svg" }

    <div class="notes">
    - Flume

    - Camus / Gobblin

    - Spark Streaming
    </div>


    ## { data-background="images/streaming-bare.svg" }
    ## { data-background="images/streaming-events-at-scale.svg" }
    ## { data-background="images/streaming-events-at-scale-with-partitioning.svg" }
    <div class="notes">
    assume for now that events have a well-defined type... they generally don't
    </div>



    # { data-background="images/svds-blank-hi.png" }
    ## Take Action 

    ## What kind of actions?

    - Notifications
    - Decorations
    - Routing / Gating
    - Counting
    - ...

    ## When to take action?

    - "batch"
    - "real-time"

    ## { data-background="images/streaming-bare.svg" }
    <div class="notes">
    if latency is ok, it might be good enough to take action from the query side

    try that first
    </div>

    ## { data-background="images/streaming-simple.svg" }
    <div class="notes">
    if lower latency is required, act directly from the streaming layer
    </div>

    ## { data-background="images/streaming-with-notify-queues.svg" }
    <div class="notes">
    </div>

    ## { data-background="images/streaming-two-layers.svg" }


    # { data-background="images/svds-blank-hi.png" }
    ## Recognize Activity 

    ## What's activity?

    Sequence of events

    <div class="notes">
    we talked about one event

    Some activity has more than one event

    context matters
    </div>

    ## { data-background="images/classifying-simple.svg" }

    ## { data-background="images/classifying-with-state.svg" }
    <div class="notes">
    add hbase to store state

    hbase can be joined with events by impala

    hbase can be queried from stream

    examples
    </div>
    ## { data-background="images/hbase-state-credit-score.svg" }
    ## { data-background="images/classifying-with-state.svg" }
    ## { data-background="images/hbase-state-tracking-package.svg" }
    ## { data-background="images/classifying-with-state.svg" }
    ## { data-background="images/hbase-state-tracking-package-derived.svg" }
    ## { data-background="images/classifying-with-state.svg" }

    ## State
    ![](images/simple-state.png)
    <div class="notes">
    from: http://tynerblain.com/blog/2007/03/21/use-case-vs-statechart/
    </div>

    ## A Toaster
    ![](images/toaster-state.png)
    <div class="notes">
    from: https://en.wikipedia.org/wiki/Finite-state_machine
    </div>

    ## Netflix
    ![](images/play-state.jpg)
    <div class="notes">
    http://people.westminstercollege.edu/faculty/ggagne/may2012/lab8/index.html
    </div>

    ## Package State
    ![](images/package-state.jpg)
    <div class="notes">
    http://www.cse.lehigh.edu/~glennb/oose/ppt/17Activity-State-Diagrams.ppt
    </div>

    ## Complex Package State
    ![](images/nested-package-state.jpg)
    <div class="notes">
    http://www.cse.lehigh.edu/~glennb/oose/ppt/17Activity-State-Diagrams.ppt
    </div>

    ## { data-background="images/state-can-feed-forward-too.svg" }


    # { data-background="images/svds-blank-hi.png" }
    ## Best Practices

    ## The Power of the Query Side

    ## Infrastructure Aspirations
    - immutable
    - lazy
    - atomic
        - simple
        - composable
        - testable
    <div class="notes">
    When building datascience pipelines, these paradigms 
    help you stay flexible and scalable
    </div>

    ## Automate All of the Things
    <div class="notes">
    DevOps is your friend
    </div>

    ## Test All of the Things
    <div class="notes">
    TDD/BDD is your friend
    </div>

    ## Failure is a First Class Citizen
    <div class="notes">
    Fail fast, early, often
    </div>


    # { data-background="images/svds-blank-hi.png" }
    ## Wrap-up

    - Ingest Events
    - Take Action
    - Recognize Activity

    ## { data-background="images/classifying-with-state.svg" }






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

