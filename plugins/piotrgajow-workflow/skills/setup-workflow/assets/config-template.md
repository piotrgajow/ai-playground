---
work_dir: .workflow/features
work_dir_gitignored: false
docs: []
conventions:
  docs: []
  skills: []
verify:
  - name: check
    command: npm run check
    cwd: .
git:
  base_branch: main
  branch_format: feature/{slug}
  commit_format: "feat({slug}): {task_title}"
tickets:
  source: text
retry_limit: 2
---

# Workflow notes

Optional free-text guidance per step. Delete sections you do not need.

## refine

## plan

## execute

## review
