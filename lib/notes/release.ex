defmodule Notes.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :notes

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  def seed do
    load_app()
    start_repo()
    run_seeds()
  end

  defp run_seeds do
    path = Application.app_dir(@app, "priv/repo/seeds.exs")
    Code.eval_file(path)
  end

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end

  defp start_repo do
    {:ok, _} = Application.ensure_all_started(:ecto_sql)
    {:ok, _} = Notes.Repo.start_link()
  end
end
