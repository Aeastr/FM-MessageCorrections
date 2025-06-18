# 🧪 Foundation Models Demo - Message Corrections

A simple SwiftUI demo showcasing Apple's Foundation Models framework for detecting and applying message corrections. Built to explore the `@Generable` and `@Guide` macros for structured AI outputs.

> *"still playing with FoundationModels, made a little messages demo tonight that picks up when you try to correct yourself. the generable and guide macros make it super easy to steer the ai's output. really straightforward for building small, reliable structured outputs"*
> 
> — [Tweet](https://x.com/AetherAurelia/status/1935123747771400404)

## 🎯 What This Demonstrates

- **Foundation Models integration** with structured outputs
- **@Generable and @Guide macros** for steering AI responses
- **Real-time correction detection** as you type
- **Debounced AI requests** to prevent spam

## 🚀 How It Works

The demo detects when you're trying to correct a previous message and uses Foundation Models to suggest the full corrected text.

### **Simple Flow**
1. Type a message with typos → Send it
2. Start typing a correction (e.g., "friends*") 
3. AI detects it's a correction → Shows suggestion
4. Apply the correction to update the original message

### **Example**
- Previous: `"New oykr is probably the move"`
- Type: `"new york*"`
- AI suggests: `"New York is probably the move"`

## 🔧 Foundation Models Implementation

The key is using `@Generable` and `@Guide` to get structured outputs:

```swift
@Generable
struct MessageCorrectionGenerable {
    @Guide(description: "The COMPLETE corrected sentence. If a correction is detected, return the FULL original sentence with the corrected part replaced. If no correction is made, return the original Previous Message unchanged. NEVER return just the correction word alone.")
    let message: String

    @Guide(description: "True if the newly typed text was a correction or clarification to the immediately preceding message, False otherwise.")
    let isCorrection: Bool
}
```

### **Usage**
```swift
let session = LanguageModelSession(instructions: instructions)
let response = try await session.respond(
    to: prompt,
    generating: MessageCorrectionGenerable.self,
    includeSchemaInPrompt: true
)
```

## 🎯 Why This Matters

Foundation Models makes it **really straightforward** to build small, reliable structured outputs. The `@Generable` and `@Guide` macros let you steer the AI's response format without complex parsing.

Perfect for demos and prototypes where you need reliable AI responses! 

---

*Made with 🪄✨❤️ by Aether* 