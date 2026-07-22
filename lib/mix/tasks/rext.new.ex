defmodule Mix.Tasks.Rext.New do
  @shortdoc "Generate a new rext desktop app"
  @moduledoc """
  Scaffold a new rext desktop application.

      mix rext.new my_app

  Produces a minimal project wired to `rext`: a counter window, an app module
  declaring its windows, and config pointing `:rext, :app` at it. Drive the
  generated app with an agent via `mix rext.connect` + `Rext.Test` over dist.

  This is the prototype's inline generator. The shipped form is a Mix archive
  (`mix archive.install hex rext_new`), same as `mob_new`.
  """
  use Mix.Task

  @impl true
  def run([name]) when is_binary(name) do
    base = Path.expand(name)
    app = base |> Path.basename() |> Macro.underscore()
    mod = Macro.camelize(app)

    write(base, "mix.exs", mix_exs(app, mod))
    write(base, "config/config.exs", config_exs(mod))
    write(base, "lib/#{app}/application.ex", application_ex(mod))
    write(base, "lib/#{app}/counter_window.ex", counter_window_ex(mod))

    Mix.shell().info("""

    Created #{name}/. Next:

        cd #{name}
        mix deps.get
        (cd deps/rext/native/macos && ./build.sh)   # build the render backend
        mix rext.run                                 # open the window
        mix rext.connect                             # drive it from IEx / an agent
    """)
  end

  def run(_), do: Mix.raise("usage: mix rext.new NAME")

  defp write(base, rel, contents) do
    path = Path.join(base, rel)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
    Mix.shell().info("  * creating #{rel}")
  end

  defp mix_exs(name, mod) do
    """
    defmodule #{mod}.MixProject do
      use Mix.Project

      def project do
        [app: :#{name}, version: "0.1.0", elixir: "~> 1.19", deps: deps()]
      end

      def application do
        [extra_applications: [:logger], mod: {#{mod}.Application, []}]
      end

      defp deps do
        [
          {:rext, path: "../rext"},
          {:rext_dev, path: "../rext_dev", only: :dev, runtime: false}
        ]
      end
    end
    """
  end

  defp config_exs(mod) do
    """
    import Config

    # rext boots this app's windows (see Rext.App).
    config :rext, :app, #{mod}
    """
  end

  defp application_ex(mod) do
    """
    defmodule #{mod}.Application do
      use Application

      @impl true
      def start(_type, _args) do
        Supervisor.start_link([], strategy: :one_for_one, name: #{mod}.Supervisor)
      end
    end

    defmodule #{mod} do
      use Rext.App

      @impl true
      def windows do
        [{#{mod}.CounterWindow, id: "main", title: "#{mod}", size: {420, 300}}]
      end
    end
    """
  end

  defp counter_window_ex(mod) do
    """
    defmodule #{mod}.CounterWindow do
      use Rext.Window

      @impl true
      def mount(_params, socket), do: {:ok, Rext.Socket.assign(socket, :count, 0)}

      @impl true
      def render(assigns) do
        %{
          type: :column,
          props: %{gap: :space_lg, padding: :space_xl, background: :background},
          children: [
            %{type: :text, props: %{text: "Count: \#{assigns.count}", size: 34, color: :on_background}, children: []},
            %{type: :button, props: %{label: "Increment", on_click: :inc, color: :primary}, children: []}
          ]
        }
      end

      @impl true
      def handle_event("click", %{"tag" => "inc"}, socket) do
        {:noreply, Rext.Socket.update(socket, :count, &(&1 + 1))}
      end
    end
    """
  end
end
