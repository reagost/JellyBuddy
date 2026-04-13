# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PhoneClaw is a local AI Agent for iPhone that runs entirely on-device using Gemma 4 via MLX. It features a file-driven skill system where each capability is defined by a SKILL.md file — no recompilation needed to add/modify skills.

## Build & Run Commands

```bash
cd PhoneClaw
pod install              # Install dependencies (Yams for YAML parsing)
open PhoneClaw.xcworkspace  # Always open .xcworkspace, never .xcodeproj
```

- Requires: macOS + Xcode 16, iOS 17+, CocoaPods, a real device with Apple ID
- Models are downloaded on-device by default (shell install flow)
- To bundle a model: download to `Models/gemma-4-e2b-it-4bit` or `Models/gemma-4-e4b-it-4bit`, add folder reference to Xcode's Copy Bundle Resources

## Architecture

### Request Routing (5 Paths)
Defined in `AgentEngine.processInput()` and `Router.swift`:
- **VLM** — multimodal (images/audio) requests
- **Planner** — multi-skill requests requiring structured planning
- **Agent** — single skill requests with full tooling prompt
- **Light** — pure chat, no skill injection
- Preflight shortcuts skip LLM entirely for high-frequency operations

Routing is determined by `shouldUsePlanner`, `shouldUseFullAgentPrompt`, and `requiresMultimodal`. Model-specific capability flags (e.g., `supportsStructuredPlanning`) are used instead of hardcoded model IDs.

### Core Components
- **AgentEngine** (`Agent/AgentEngine.swift`) — main orchestrator, handles message flow and session management
- **Router** (`Agent/Engine/Router.swift`) — skill matching via SKILL.md triggers, supports sticky routing for multi-turn conversations
- **ToolRegistry** (`Tools/ToolRegistry.swift`) — centralized native API tool registration
- **SkillRegistry/SkillLoader** (`Skills/SkillLoader.swift`) — parses SKILL.md frontmatter and body
- **MLXLocalLLMService** (`LLM/MLX/MLXLocalLLMService.swift`) — MLX-based LLM inference with streaming
- **Planner** (`Agent/Engine/Planner.swift`) — two-step LLM planning (Selection → Planning) for multi-skill orchestration

### Skill System
Skills are defined by `SKILL.md` files with YAML frontmatter:
```yaml
---
name: SkillName
type: device|content   # device = iOS API calls, content = text transformation
triggers:
  - keyword
allowed-tools:
  - tool-name
---
# Skill body (instructions for the model)
```

- Built-in skills: `PhoneClaw/Skills/Library/{calendar,clipboard,contacts,health,reminders,translate}/SKILL.md`
- Custom skills: `Application Support/PhoneClaw/skills/<skill-id>/SKILL.md` (hot-reloadable)
- Tool handlers: `Tools/Handlers/{Calendar,Clipboard,Contacts,Health,Reminders}.swift`

### KV Cache Reuse
`MLXLocalLLMService+KVReuse.swift` enables cross-turn cache reuse via `MLX.GPU.save/load`，reducing time-to-first-token by ~3.5x for consecutive queries within the same skill context.

### Architecture Decisions
Key decisions are documented in `PhoneClaw/doc/architecture-decisions.md`, including:
- Why 5-path routing over unified ReAct
- Why `parseToolCall() == nil` over `[STATUS:COMPLETED]` terminators
- Why Selection → Planning stays two-step
- Why E2B doesn't attempt sequential fallback for multi-skill

## Key Files
- `PhoneClaw/Agent/AgentEngine.swift` — entry point for `processInput()`
- `PhoneClaw/LLM/MLX/MLXLocalLLMService.swift` — LLM service, model loading, streaming
- `PhoneClaw/LLM/PromptBuilder.swift` — constructs system prompts with skill injection
- `PhoneClaw/Agent/Engine/ToolChain.swift` — executes tool call sequences
- `PhoneClaw/Agent/Engine/SessionStore.swift` — chat history persistence
- `PhoneClaw/Packages/InferenceKit/` — MLXLLM/MLXLMCommon/MLXVLM libraries vendored as local packages
