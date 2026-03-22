---
name: feedback_magic_numbers
description: Avoid magic numbers — extract repeated values into named constants
type: feedback
---

Don't use magic numbers in code. Extract repeated values into named constants with descriptive names.

**Why:** User values code clarity and maintainability — magic numbers obscure intent.

**How to apply:** Whenever a literal number appears more than once or has domain meaning, define it as a named constant. This applies to defaults, thresholds, and configuration values throughout the codebase.
