defmodule IssuesLeaderboard.PageController do
  use IssuesLeaderboard.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
