# Global Codex instructions

## Markdown documentation

- Keep every Markdown line at or below 100 characters.
- Reflow prose, lists, and headings instead of relying on horizontal scrolling.
- Avoid Markdown tables when their rows would exceed the limit; use lists instead.
- Prefer short canonical reference URLs when an equivalent official URL exists.
- Give substantial concepts or knowledge areas their own focused Markdown documents.
- Cross-link focused documents from the project index or primary investigation document.
- Keep detailed references in the focused document they support.
- After changing Markdown, run the global checker from the project root:
  `rtk python3 ~/config_files/codex/scripts/check-markdown-line-length.py .`
