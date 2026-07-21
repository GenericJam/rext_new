# rect_new — Agent Instructions

Project generator for [rect](../rect). **Read `../rect/CLAUDE.md` first** for the
shared knowledge (toolchain paths, quality gates, the "don't write slop" list).
This file covers only what's specific to rect_new.

## What it does

`mix rect.new my_app` scaffolds a minimal rect project: a counter window, an app
module declaring its windows (`Rect.App`), `config :rect, :app`, and a
`.mcp.json` so an agent session gets rect's tools with zero setup (the agent
story is present from generation onward, mirroring `mob_new`).

The task takes a name or a path; it derives the app name from the basename
(`Macro.underscore`) and the module from that (`Macro.camelize`). Templates are
inline heredocs in `lib/mix/tasks/rect.new.ex` — keep them compiling against the
current `rect` API (Window/Socket/App), since a generator that emits stale code
is worse than none.

## Shipped form

The shipped form is a Mix archive (`mix archive.install hex rect_new`), same as
`mob_new`. For now it's run in-repo.

## Toolchain / quality

Same as rect — see `../rect/CLAUDE.md`:

```bash
export PATH="/Users/kevin/.local/share/mise/installs/erlang/29.0/bin:/Users/kevin/.local/share/mise/installs/elixir/1.20.0-otp-29/bin:$PATH"
mix test && mix format && mix credo --strict && mix compile --warnings-as-errors
```

rect_new is standalone (no `rect` dep — it only writes files), so CI is simple.

## Testing discipline

The generator is CLI surface, so it gets tests like everything else: generate
into a temp dir and assert the files exist and contain the expected module
names. See `test/`. When you change a template, update the test.
