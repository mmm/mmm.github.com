---
layout: post
title: "Educational Components"
date: 2014-10-24 14:48
comments: true
categories: datascience
---

I'm trying to frame the most basic and naive understanding of education and
learning.  The goal is to have something amenable to various machine learning
techniques... mostly just to see what comes out.

<!--more-->

I taught Physical Science at UT for, hell, pretty much my entire tenure in grad
school.  During that time, I spent a lot of time and effort trying to find
better ways of explaining things, better ways to reach people, better ways to
connect physics concepts to my student's everyday lives.  Ok, so maybe all I
really did was spend my time and energy battling math anxiety, but that's
another discussion.

In any case, I spent time thinking about the subject itself and how to make it
simpler, that I never really explicitly thought about the learner, the learning
process, variations in learning, etc etc.  I figured if you danced and sang and
explained each thing six ways to Sunday, then you'd get something through the
fog eventually.

So here's my first pass at understanding education.


## activity

### characteristic functions

A characteristic function for a set is useful in analysis when you're trying to
measure things about that set.  It's a common tool used in signal processing,
it's used to define Lebesgue integration, used in PDEs for various transforms,
etc.

It's a simple function

$$
\phi_A(x) = 
  \left\{
    \begin{array}{ll}
      1 & \mbox{if } x \in A \\
      0 & \mbox{otherwise }
    \end{array}
  \right.
$$

that takes a value of `1` for any domain entry that's 
a member of the set `A`, `0` otherwise.

Now we can integrate a characteristic function over intervals and establish
some notion of size of the set

$$
\mbox{size of A} = \int_A \phi_A(x) dx.
$$

Ok, so what does all this have to do with education and learning?

Well, I'll make an assumption that we can define learning, define learning
activity, and also determine when a student is engaged in a learning activity
or not at any given moment.

Let's define a function similar to a characteristic function
that identifies activity over time.
I.e., some function

$$
\alpha(t) = 
  \left\{
    \begin{array}{ll}
      1 & \mbox{if student is actively learning} \\
      0 & \mbox{otherwise }
    \end{array}
  \right.
$$

that registers when learning is occurring.
I'm totally still being vague about what learning or learning
activity might mean for the moment.  We'll come back to this in a bit.




As before, there are links to the whole series of charmschool hangouts in the juju
where we also have videos and screencasts of demos, talks,  and any other charm
schools we've been able to capture on video.









