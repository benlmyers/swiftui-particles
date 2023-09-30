# Particles 🎉

🚧 This Swift package is under construction. **But...**

### Who knew creating particles in SwiftUI could be so easy?

```swift
var body: some View {
  Emitter(from: .center, to: .trailing) { // Emit particles from the center of the view to the right side of the view
    Confetti(.rainbow) // Emit rainbow confetti
  }
  .emitVelocity(x: 100.0, y: -100.0) // Emit up and to the right initially
  .emitForever(intensity: 20) // Emit 20 particles forever
  .particleLifetime(0.75) // Each particle will have an animate 0.75s
  .emitSpread(0.4) // The particles will spread out as they are emitted
}
```

Improved features, documentation, and tutorials are coming in the near future. If you want to use this Swift package in your project, ensure that you do so under the dependency rule on branch `main`.

// TODO: Make copying start value behavior based off emitter as input (not existing Entity or prototype Entity)
