defmodule IssuesLeaderboard.DefaultBoard do
  use GenServer

  def start_link do
    {:ok, _pid} = IssuesLeaderboard.Board.start_link("2015-09-10T00:00:00Z", "will smith")
  end
end