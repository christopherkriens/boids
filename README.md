<img src="http://www.christopherkriens.com/github/boids.png" width="420" />

#### Two dimensional implementation of Boids using SpriteKit and Swift 3.

###### Now with more emotes! 🐟 🐔 🦄

## Overview
Boids is an algorithm for simulating natural group flocking behavior.  Flocking is an emergent behavior accomplished by applying a set of simple rules on autonomous agents, called "boids".  Each boid operates independently, assessing its surrounding flock and adjusting its heading based on an evaluation of a set of basic rules.
<br /><br /><img src="http://img.shields.io/badge/License-MIT-red.svg"> <img src="http://img.shields.io/badge/Platforms-iOS-lightgrey.svg"> <img src="http://img.shields.io/badge/Swift-3.1-orange.svg">

## Rules
The standard flocking rules:

> **1. Cohesion:** Steer toward the average position of nearby agents <br/><br/>**2. Alignment:** Maintain a heading similar to the average heading of nearby agents<br/><br/>**3. Separation:** Steer away from agents that are close to avoid crowding


In addition to the standard flocking rules, I've added:

> **4. Bound:** Steer away from the bounds of the device screen to keep agents in view


## Interaction

A touch adds a temporary rule:

> **6. Seek:** Move toward the current touch position

A force touch adds a temporary rule:

> **7. Evade:** Move away from the current touch position


## Preview

<img src="http://www.christopherkriens.com/github/demo.gif" width="660" />

## Usage
```swift
// Initialize and add a Boid SpriteNode to the Scene
let boid = Boid(withCharacter: "🐡", andSize: 40)
addChild(boid)
```

```swift
// Configure the boid's behaviors.. or don't; whatever, it's your life
self.behaviors = [Cohesion(intensity: 0.1), Separation(intensity: 0.1), Alignment(intensity: 1.0)]
```

## Performance
Because each boid needs to iterate over the entire group, this runs in quadratic time _O(n²)_.  As a benchmark, the iPhone 6S can maintain 60fps when simulating up to 100 boids.


## Source Versioning
* Xcode 8.3.2
* iOS SDK 10.3.2
* Swift 3.1

## Credit

**Original Paper:** Craig W. Reynolds (1987). [Flocks, Herds, and Schools:
A Distributed Behavioral Model](http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/)

**Pseudocode:** Conrad Parker (2007). [Boids Pseudocode](http://www.kfish.org/boids/pseudocode.html)
