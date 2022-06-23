# Particles 🎉

🚧 This Swift package is under construction. **But...**

### Who knew creating particles in SwiftUI could be so easy?

```swift
var body: some View {
  Emitter(from: .center, to: .trailing) {
    Confetti(.rainbow)
  }
  .emitVelocity(x: 100.0, y: -100.0)
  .emitForever(intensity: 20)
  .particleLifetime(0.75)
  .emitSpread(0.4)
}
```

Improved features, documentation, and tutorials are coming in the near future. If you want to use this Swift package in your project, ensure that you do so under the dependency rule on branch `main`.
