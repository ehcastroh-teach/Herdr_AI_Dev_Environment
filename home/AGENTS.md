# Global Memory: Instructions for all agents across all scenarios.

**Agent Rules**

- Never use em-dash. Use plain dash instead.
- When writing commit messages, never auto-add your agent's name as co-author.
- Never manually modify CHANGELOG.md files or any files marked as auto-generated.
- When making technical decisions, do not give much weight to development cost.
  Prefer quality, simplicity, robustness, scalability, and long-term maintainability.
- When doing bug fixes, always start by reproducing the bug end-to-end, as closely
  aligned with how an end user would experience it as possible.
- When end-to-end testing, be picky about the UI and obsessed with pixel perfection.
  If something looks off, even unrelated to the task, try to fix it along the way.
- Apply the same standard to lint, test failures, and flakiness: see it, fix it.
