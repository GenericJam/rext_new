# rext_new — Agent Instructions

Project generator for [rext](../rext). **Read `../rext/CLAUDE.md` first** for the
shared knowledge (toolchain paths, quality gates, the "don't write slop" list).
This file covers only what's specific to rext_new.

## What it does

`mix rext.new my_app` scaffolds a minimal rext project: a counter window, an app
module declaring its windows (`Rext.App`), and `config :rext, :app`. Agents drive
the generated app via `mix rext.connect` + `Rext.Test` over dist — no `.mcp.json`
/ MCP server (deliberately not pursued; see `../rext/decisions`).

The task takes a name or a path; it derives the app name from the basename
(`Macro.underscore`) and the module from that (`Macro.camelize`). Templates are
inline heredocs in `lib/mix/tasks/rext.new.ex` — keep them compiling against the
current `rext` API (Window/Socket/App), since a generator that emits stale code
is worse than none.

## Shipped form

The shipped form is a Mix archive (`mix archive.install hex rext_new`), same as
`mob_new`. For now it's run in-repo.

## Toolchain / quality

Same as rext — see `../rext/CLAUDE.md`:

```bash
export PATH="/Users/kevin/.local/share/mise/installs/erlang/29.0/bin:/Users/kevin/.local/share/mise/installs/elixir/1.20.0-otp-29/bin:$PATH"
mix test && mix format && mix credo --strict && mix compile --warnings-as-errors
```

rext_new is standalone (no `rext` dep — it only writes files), so CI is simple.

## Testing discipline

The generator is CLI surface, so it gets tests like everything else: generate
into a temp dir and assert the files exist and contain the expected module
names. See `test/`. When you change a template, update the test.
