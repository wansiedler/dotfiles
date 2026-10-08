#!/usr/bin/env python3
"""PreToolUse hook: enforce the git/GitHub policy from ~/.claude/CLAUDE.md.

ALLOW:  git commit / git push on FEATURE branches; gh pr create --draft.
BLOCK:  commit or push on protected branches (main/master/develop/release/*/integration/*),
        pushing a protected ref, and non-draft `gh pr create`.

Detection is by git SUBCOMMAND (not substring), so read-only commands whose
flags/format strings contain the words "commit"/"push" (git blame/log/show/diff)
are never blocked.

exit 2 = block the tool call; stderr is fed back to Claude.
"""
import json, re, shlex, subprocess, sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

cmd = (data.get("tool_input") or {}).get("command", "") or ""

PROTECTED = re.compile(r"^(main|master|develop|release/.*|integration/.*)$")


def block(msg):
    sys.stderr.write("BLOCKED by policy (~/.claude/CLAUDE.md): " + msg + "\n")
    sys.exit(2)


def branch_in(cwd):
    try:
        args = ["git"]
        if cwd:
            args += ["-C", cwd]
        args += ["rev-parse", "--abbrev-ref", "HEAD"]
        return subprocess.check_output(args, stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


# split a compound command into segments on && || ; | & and newlines
segs = re.split(r"\s*(?:&&|\|\||[;&\n|])\s*", cmd)
cwd = None

for seg in segs:
    try:
        toks = shlex.split(seg)
    except Exception:
        toks = seg.split()
    if not toks:
        continue

    # track `cd <dir>` so branch checks run in the right repo
    if toks[0] == "cd" and len(toks) > 1:
        cwd = toks[1]
        continue

    # skip leading env assignments / sudo / env
    i = 0
    while i < len(toks) and ("=" in toks[i] or toks[i] in ("sudo", "env")):
        i += 1
    if i >= len(toks):
        continue

    prog = toks[i]
    rest = toks[i + 1:]

    # honor `git -C <path>` for the branch check, and skip flags when finding the subcommand
    git_cwd = cwd
    j = 0
    while j < len(rest):
        if rest[j] == "-C" and j + 1 < len(rest):
            git_cwd = rest[j + 1]
            j += 2
        elif rest[j].startswith("-"):
            j += 1
        else:
            break
    sub = rest[j] if j < len(rest) else ""
    args_after = rest[j + 1:]

    if prog == "git":
        if sub == "commit":
            br = branch_in(git_cwd)
            if PROTECTED.match(br):
                block(f"commit on protected branch '{br}'. Create a feature branch first "
                      f"(git checkout -b <feature> {br}), then open a draft PR.")
        elif sub == "push":
            # candidate destination refs: explicit non-flag args (minus remote) + current branch
            names = []
            for t in args_after:
                if t.startswith("-") or t in ("origin", "upstream"):
                    continue
                names.append(t.split(":")[-1])  # local:remote -> remote side
            names.append(branch_in(git_cwd))
            for n in names:
                if n and PROTECTED.match(n):
                    block(f"push to protected branch '{n}'. Push a feature branch and open a draft PR instead.")
    elif prog == "gh":
        if sub == "pr":
            action = next((t for t in args_after if not t.startswith("-")), "")
            if action == "create" and "--draft" not in args_after:
                block("only DRAFT PRs are allowed. Add --draft to `gh pr create`.")

sys.exit(0)
