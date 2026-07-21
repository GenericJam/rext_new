# rect_new

Project generator for [rect](https://github.com/GenericJam/rect) desktop apps —
a BEAM-on-desktop UI framework for Elixir.

```bash
mix rect.new my_app
```

Scaffolds a minimal project wired to `rect`: a counter window, an app module
declaring its windows (`Rect.App`), config pointing `:rect, :app` at it, and a
`.mcp.json` so an agent session gets rect's tools with zero setup.

The shipped form is a Mix archive (`mix archive.install hex rect_new`), same as
`mob_new`. See `CLAUDE.md` for details.
