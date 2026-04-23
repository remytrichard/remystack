# AI Code Review — Implementation Notes

## Design Choices

### Trigger Strategy
- **Pull requests:** Fires on `opened` and `synchronize` so reviews are posted when a PR is created or updated.
- **Manual dispatch:** `workflow_dispatch` with an optional `pr_number` input allows testing the workflow on demand without creating dummy PRs.

### Cost & Safety Controls
- **Draft PR skip:** The job-level `if` prevents burning tokens on work-in-progress drafts.
- **Diff size cap:** 150 KB (~37K tokens at 4 chars/token). This leaves room for the system prompt and model response while staying well under the ~50K token requirement.
- **Exclusions:** `node_modules`, `vendor`, and `*.lock` files are excluded from the diff to avoid noise.

### Diff Generation
- Uses `git diff origin/<base>...HEAD` so the review covers exactly the changes introduced by the PR, not merge commits or unrelated history.
- `fetch-depth: 0` ensures the base branch is available for comparison.

### LLM Integration
- **Provider:** OpenRouter (aggregates multiple providers, cheap & fast).
- **Model:** `qwen/qwen3.5-plus-02-15` — chosen for low cost, speed, and adequate reasoning for shell/markdown diffs.
- **Prompt:** Structured system prompt forces output into four buckets (Critical / Warnings / Suggestions / Looks Good), reducing hallucination and making reviews scannable.
- **Security:** The API key is injected via `env` (`OPENROUTER_API_KEY`) and passed to `curl` in a header. It never appears in logs because `curl` does not echo headers unless `-v` is used.

### Posting Reviews
- Uses `actions/github-script@v7` (native GitHub Action, no Docker) to post comments via the REST API.
- `GITHUB_TOKEN` is used for authentication; it is automatically scoped by the `permissions` block (`pull-requests: write`).
- If the API call fails, a failure comment is posted so the PR author knows the review was attempted.

### Error Handling
- `set -euo pipefail` in the bash step ensures any unexpected failure aborts the step cleanly.
- HTTP status from `curl` is explicitly checked. Non-200 responses are logged (body only, no headers/secrets) and cause the step to fail gracefully.
- The `failure()` guard on the final step ensures a human-readable comment is posted even when the LLM call errors out.
