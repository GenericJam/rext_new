defmodule Mix.Tasks.Rect.New do
  @shortdoc "Generate a new rect desktop app"
  @moduledoc """
  Scaffold a new rect desktop application.

      mix rect.new my_app

  Produces a minimal project wired to `rect`, with a counter window, an app
  module declaring its windows, config pointing `:rect, :app` at it, and a
  `.mcp.json` so an agent session gets rect's tools with zero setup (mirrors
  mob_new's plan — the agent story is present from generation onward).

  This is the prototype's inline generator. The shipped form is a Mix archive
  (`mix archive.install hex rect_new`), same as `mob_new`.
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
    write(base, ".mcp.json", mcp_json())

    Mix.shell().info("""

    Created #{name}/. Next:

        cd #{name}
        mix deps.get
        (cd deps/rect/native/macos && ./build.sh)   # build the render backend
        mix rect.run                                 # open the window
        mix rect.connect                             # drive it from IEx / an agent
    """)
  end

  def run(_), do: Mix.raise("usage: mix rect.new NAME")

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
          {:rect, path: "../rect"},
          {:rect_dev, path: "../rect_dev", only: :dev, runtime: false}
        ]
      end
    end
    """
  end

  defp config_exs(mod) do
    """
    import Config

    # rect boots this app's windows (see Rect.App).
    config :rect, :app, #{mod}
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
      use Rect.App

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
      use Rect.Window

      @impl true
      def mount(_params, socket), do: {:ok, Rect.Socket.assign(socket, :count, 0)}

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
        {:noreply, Rect.Socket.update(socket, :count, &(&1 + 1))}
      end
    end
    """
  end

  defp mcp_json do
    """
    {
      "mcpServers": {
        "rect": {
          "command": "mix",
          "args": ["rect_mcp.server"]
        }
      }
    }
    """
  end
end
