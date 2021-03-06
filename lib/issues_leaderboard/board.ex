defmodule IssuesLeaderboard.Board do
  use Supervisor

  def start_link(after_date, theme_query) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, {after_date, theme_query})
  end

  def init({after_date, theme_query}) do
    child_processes = [
      worker(IssuesLeaderboard.Leaderboard,
        [%BoardConfig{
           repo: System.get_env("GITHUB_REPO"),
           label: System.get_env("GITHUB_LABEL"),
           after_date: after_date}]),
      worker(IssuesLeaderboard.ThemeCreator, [theme_query])
    ]
    supervise child_processes, strategy: :one_for_one
  end
end
