defmodule Mix.Tasks.CreateDatabase do
  @moduledoc """
  Create a database with a schema, that locks the user into the schema.
  """
  use Mix.Task
  import Mix.Ecto

  @aliases [
    q: :quiet,
    r: :repo,
  ]

  @shortdoc "Creates a database with matching schema"

  @switches [
    quiet: :boolean,
    repo: [:string, :keep],
  ]

  def run(args) do
    repos = parse_repo(args)
    {opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    Enum.each repos, fn repo ->
      ensure_repo(repo, args)

      db_name = repo.config()[:database]
      db_user = repo.config()[:username]

      # Create role and database
      psql_run("CREATE ROLE #{db_user} WITH CREATEDB LOGIN;", opts)
      psql_run("CREATE DATABASE #{db_name} WITH OWNER #{db_user};", opts)

      # Remove the role's ability to create anything in the public schema
      psql_run(db_name, "REVOKE ALL ON SCHEMA public FROM PUBLIC;", opts)
      psql_run(db_name, "REVOKE USAGE ON SCHEMA public FROM #{db_user};", opts)

      # Create the schema if it doesn't exist, and grant the role full priviledges
      psql_run(db_name, "CREATE SCHEMA IF NOT EXISTS #{db_user};", opts)
      psql_run(db_name, "GRANT ALL ON SCHEMA #{db_user} TO #{db_user};", opts)

      # Set the role's search_path to only include the schema
      psql_run(db_name, "ALTER ROLE #{db_user} SET search_path=#{db_user};", opts)
    end
  end

  defp psql_run(cmd, opts) do
    System.cmd("psql", ["-c", cmd], stderr_to_stdout: !!opts[:quiet])
  end
  defp psql_run(db_name, cmd, opts) do
    System.cmd("psql", [db_name, "-c", cmd], stderr_to_stdout: !!opts[:quiet])
  end
end
