# Claude Agent System

This directory contains the agent orchestration system for WristArcana, adapted from the ml-odyssey repository.

## Overview

The agent system provides a hierarchical structure for delegating complex tasks to specialized agents. This ensures focused expertise, clear responsibility boundaries, and efficient collaboration.

## Directory Structure

```
.claude/
├── README.md              # This file
├── agents/                # Agent definitions
│   ├── chief-architect.md        # Level 0: Strategic orchestrator
│   ├── app-orchestrator.md       # Level 1: watchOS app implementation
│   ├── testing-orchestrator.md   # Level 1: Testing strategy
│   ├── cicd-orchestrator.md      # Level 1: CI/CD & automation
│   └── documentation-orchestrator.md # Level 1: Documentation
├── shared/                # Shared constraints and rules
│   ├── common-constraints.md
│   ├── documentation-rules.md
│   └── error-handling.md
├── skills/                # Reusable skills (reserved for future use)
└── commands/              # Custom commands (reserved for future use)
```

## Agent Hierarchy

### Level 0: Chief Architect
**File:** `agents/chief-architect.md`
**Model:** opus
**Role:** Strategic orchestrator for system-wide decisions

**When to use:**
- Repository-wide architectural decisions
- Feature epic planning
- Technology stack decisions
- Breaking down large initiatives into coordinated tasks

**Delegates to:**
- App Orchestrator
- Testing Orchestrator
- CI/CD Orchestrator
- Documentation Orchestrator

### Level 1: Section Orchestrators

#### App Orchestrator
**File:** `agents/app-orchestrator.md`
**Model:** sonnet
**Role:** watchOS SwiftUI/SwiftData implementation

**Responsibilities:**
- SwiftUI views and components
- ViewModels and state management
- SwiftData models and persistence
- Navigation patterns
- UI testing

#### Testing Orchestrator
**File:** `agents/testing-orchestrator.md`
**Model:** sonnet
**Role:** Comprehensive testing strategy

**Responsibilities:**
- Test planning and implementation
- Coverage analysis (>50% overall, 95%+ models/viewmodels)
- Manual testing coordination
- Quality gates

#### CI/CD Orchestrator
**File:** `agents/cicd-orchestrator.md`
**Model:** sonnet
**Role:** Pipeline and automation

**Responsibilities:**
- GitHub Actions workflows
- Pre-commit hooks
- Quality gates
- Build automation

#### Documentation Orchestrator
**File:** `agents/documentation-orchestrator.md`
**Model:** sonnet
**Role:** Documentation strategy

**Responsibilities:**
- README and guide maintenance
- Architecture documentation
- Process documentation

## How to Use

### Using the Chief Architect

When you have a large, complex task:

```
@chief-architect I need to implement a new feature that allows users to
export their tarot reading history as a PDF. Please coordinate the
implementation across app development, testing, and documentation.
```

The chief-architect will:
1. Analyze the requirements
2. Define the architecture
3. Break down into subtasks
4. Delegate to appropriate orchestrators
5. Monitor progress and resolve conflicts

### Using Section Orchestrators

When you have a task scoped to a specific area:

```
@app-orchestrator Implement a new HistoryFilterView that allows filtering
by date range and card type.
```

```
@testing-orchestrator Add comprehensive tests for the new multi-delete
feature in HistoryViewModel.
```

### Agent Selection Guide

| Task Type | Agent to Use |
|-----------|-------------|
| Large epic spanning multiple areas | chief-architect |
| App UI/logic implementation | app-orchestrator |
| Test strategy or coverage | testing-orchestrator |
| CI/CD pipeline update | cicd-orchestrator |
| Documentation creation/update | documentation-orchestrator |

## Shared Constraints

All agents follow the constraints defined in `shared/`:

### Common Constraints
- **Minimal changes principle**: Make the smallest change that solves the problem
- **Scope discipline**: Complete assigned task, nothing more
- **No work without issue**: All work must be tracked via GitHub issues

### Documentation Rules
- Never create documentation files unless explicitly requested
- Always prefer editing existing docs to creating new ones
- Keep documentation concise and actionable

### Error Handling
- Fix root causes, not symptoms
- No shortcuts or workarounds
- Never comment out failing tests
- Never use linter bypass comments

## Why This is Gitignored

This `.claude/` directory is copied from ml-odyssey and is NOT checked into version control for WristArcana.

**Reasons:**
1. **Experimental**: Agent system is still evolving
2. **Local tool**: Intended for development workflow, not production code
3. **Easy updates**: Can pull latest from ml-odyssey without conflicts
4. **Repository-specific**: May diverge from ml-odyssey over time

**To update from ml-odyssey:**
```bash
# From wrist-arcana/
cp -r ../ml-odyssey/.claude/agents/*.md .claude/agents/
cp -r ../ml-odyssey/.claude/shared/*.md .claude/shared/
# Then adapt for WristArcana specifics
```

## Examples

### Example 1: New Feature (Card Statistics View)

**Chief Architect coordinates:**
1. App Orchestrator → Implement SwiftUI statistics views
2. Testing Orchestrator → Implement comprehensive tests
3. Documentation Orchestrator → Update feature documentation

### Example 2: Bug Fix (UI test failures #13)

**Direct to Testing Orchestrator:**
- No need for chief-architect (single-area task)
- Testing Orchestrator investigates and fixes the tests
- App Orchestrator may assist if it's an app code issue

### Example 3: Refactoring (Extract card drawing logic)

**Chief Architect coordinates:**
1. Define refactoring strategy
2. Delegate code extraction to App Orchestrator
3. Delegate test updates to Testing Orchestrator
4. Monitor integration and ensure no regressions

## Tips for Effective Use

1. **Start with Chief Architect** for anything touching multiple areas
2. **Use specific orchestrators** for focused, single-area tasks
3. **Reference GitHub issues** - all agents expect issue numbers
4. **Be explicit** about requirements and constraints
5. **Review delegation** - agents will explain their plan before executing

## Future Enhancements

- Custom skills for WristArcana-specific patterns
- Custom commands for common workflows
- Specialist agents for specific tasks (SwiftUI animations, card artwork)
- Integration with GitHub workflows

---

**Source:** Adapted from [ml-odyssey/.claude](../../ml-odyssey/.claude)
**Last Updated:** 2025-12-09
