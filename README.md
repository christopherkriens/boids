# Boids
---------------
Two dimensional implementation of Boids using SpriteKit and Swift 3.

Now with more emotes! 🐠🐠🐠

Boids is an algorithm for simulating natural group flocking behavior of birds and fish.  Flocking can be represented as an emergent behavior by applying a set of simple rules on autonomous agents, called "boids".

The standard flocking rules are:

**1. Cohesion** - Steer toward the average position of nearby agents

**2. Alignment** - Maintain a heading similar to the average heading of nearby agents

**3. Separation** - Steer away from agents that are close to avoid crowding


In addition to these flocking rules, I've added two:

**1. Bound** - Steer away from the bounds of the device screen

**2. Rejoin** - In the event that a boid has no nearby agents, increase speed and move toward the nearest agent

**Original Paper:** Craig W. Reynolds (1987). [Flocks, Herds, and Schools:
A Distributed Behavioral Model](http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/)

Source Versioning
----------------
* Xcode 8.3
* iOS 10.3 SDK
* Swift 3.1
