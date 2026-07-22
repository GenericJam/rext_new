# rext_new

Project generator for [rext](https://github.com/GenericJam/rext) desktop apps —
a BEAM-on-desktop UI framework for Elixir.

```bash
mix rext.new my_app
```

Scaffolds a minimal project wired to `rext`: a counter window, an app module
declaring its windows (`Rext.App`), and config pointing `:rext, :app` at it.
Drive the generated app with an agent via `mix rext.connect` + `Rext.Test`
over dist.

The shipped form is a Mix archive (`mix archive.install hex rext_new`), same as
`mob_new`. See `CLAUDE.md` for details.
