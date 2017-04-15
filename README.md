<img src="/Boids/boids.png" width="307">

Two dimensional implementation of Boids using SpriteKit and Swift 3.

Now with more emotes! 🐟 🐡 🦄 🐔

Boids is an algorithm for simulating natural group flocking behavior.  Flocking is an emergent behavior accomplished by applying a set of simple rules on autonomous agents, called "boids".

Rules
-----
The standard flocking rules:

**1. Cohesion** - Steer toward the average position of nearby agents

**2. Alignment** - Maintain a heading similar to the average heading of nearby agents

**3. Separation** - Steer away from agents that are close to avoid crowding


In addition to the sttandard flocking rules, I've added two:

**4. Bound** - Steer away from the bounds of the device screen to keep agents in view

**5. Rejoin** - In the event that a boid has no nearby agents, increase speed and move toward the nearest agent

Preview
-------
<img src="/Boids/demo.gif" width="660">


Source Versioning
-----------------
* Xcode 8.3
* iOS 10.3 SDK
* Swift 3.1

**Original Paper:** Craig W. Reynolds (1987). [Flocks, Herds, and Schools:
A Distributed Behavioral Model](http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/)
