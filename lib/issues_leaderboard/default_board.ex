defmodule IssuesLeaderboard.DefaultBoard do
  use GenServer

  def start_link do
    {:ok, _pid} = IssuesLeaderboard.Board.start_link(
      System.get_env("AFTER_DATE"),
      System.get_env("THEME")
    )
  end
end
