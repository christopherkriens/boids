<img src="/Boids/boids.png" width="307">

Two dimensional implementation of Boids using SpriteKit and Swift 3.

Now with more emotes! 🐟 🐡 🐔 🦄

Boids is an algorithm for simulating natural group flocking behavior.  Flocking is an emergent behavior accomplished by applying a set of simple rules on autonomous agents, called "boids".  Each boid assesses its surrounding flock and adjusts its heading based on an evaluation of a simple set of rules.

Rules
-----
The standard flocking rules:

**1. Cohesion:** Steer toward the average position of nearby agents

**2. Alignment:** Maintain a heading similar to the average heading of nearby agents

**3. Separation:** Steer away from agents that are close to avoid crowding


In addition to the standard flocking rules, I've added two:

**4. Bound:** Steer away from the bounds of the device screen to keep agents in view

**5. Rejoin:** In the event that a boid has no nearby agents, increase speed and move toward the nearest agent


Interaction
-----------
A single tap adds a behavior:

**6. Seek:** Move toward the tap position

A tap and hold or drag adds a behavoir:

**7. Evade:** Move away from the curent tap position


Preview
-------
<img src="/Boids/demo.gif" width="660">


Source Versioning
-----------------
* Xcode 8.3
* iOS SDK 10.3
* Swift 3.1

**Original Paper:** Craig W. Reynolds (1987). [Flocks, Herds, and Schools:
A Distributed Behavioral Model](http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/)
