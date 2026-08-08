defmodule Mix.Tasks.Rext.NewTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  setup do
    dir = Path.join(System.tmp_dir!(), "rext_new_test_#{System.unique_integer([:positive])}")
    on_exit(fn -> File.rm_rf!(dir) end)
    %{dir: dir}
  end

  test "generates a project with app/window/config files", %{dir: dir} do
    target = Path.join(dir, "cool_app")
    capture_io(fn -> Mix.Tasks.Rext.New.run([target]) end)

    for rel <- [
          "mix.exs",
          "config/config.exs",
          "lib/cool_app/application.ex",
          "lib/cool_app/counter_window.ex"
        ] do
      assert File.exists?(Path.join(target, rel)), "expected #{rel}"
    end
  end

  test "derives module and app names from the basename", %{dir: dir} do
    target = Path.join(dir, "cool_app")
    capture_io(fn -> Mix.Tasks.Rext.New.run([target]) end)

    mix_exs = File.read!(Path.join(target, "mix.exs"))
    assert mix_exs =~ "defmodule CoolApp.MixProject"
    assert mix_exs =~ "app: :cool_app"

    window = File.read!(Path.join(target, "lib/cool_app/counter_window.ex"))
    assert window =~ "defmodule CoolApp.CounterWindow"
    assert window =~ "use Rext.Window"

    config = File.read!(Path.join(target, "config/config.exs"))
    assert config =~ "config :rext, :app, CoolApp"
  end

  test "the generated app boots its own windows (not just leaves them to dev tooling)", %{
    dir: dir
  } do
    target = Path.join(dir, "cool_app")
    capture_io(fn -> Mix.Tasks.Rext.New.run([target]) end)

    application = File.read!(Path.join(target, "lib/cool_app/application.ex"))
    assert application =~ "Rext.boot(CoolApp)"
  end

  test "requires exactly one name argument" do
    assert_raise Mix.Error, fn -> Mix.Tasks.Rext.New.run([]) end
  end
end
