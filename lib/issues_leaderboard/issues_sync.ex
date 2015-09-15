defmodule IssuesLeaderboard.IssuesSync do
  use Timex

  @access_token System.get_env("GITHUB_TOKEN")
  @interval 60_000

  def start(after_date) do
    run(after_date)
  end

  def run(after_date) do
    issues = issues(after_date)
    IssuesLeaderboard.Endpoint.broadcast! "boards:default", "issues",
      %{issues: issues}
    :timer.sleep(@interval)
    run(after_date)
  end

  def issues(after_date) do
    fetch_issues(after_date) |> Enum.map(&serialize_issue/1)
  end

  defp client do
    Tentacat.start
    Tentacat.Client.new(%{access_token: @access_token })
  end

  defp fetch_issues(after_date) do
    Tentacat.get("repos/orgsync/orgsync/issues", client,
      [labels: "bug", state: "closed", since: after_date])
    |> Stream.filter(fn issue ->
         DateFormat.parse(issue["closed_at"], "{ISO}") >=
           DateFormat.parse(after_date, "{ISO}")
       end)
  end

  defp issue_points(issue) do
    label_names = Enum.map(issue["labels"], fn label -> label["name"] end)
    Enum.find(5..1, 0, fn points ->
      Enum.member?(label_names, to_string(points))
    end)
  end

  defp serialize_issue(issue) do
    %{
      number: issue["number"],
      title: issue["title"],
      assignee: %{
        username: issue["assignee"]["login"],
        avatar_url: issue["assignee"]["avatar_url"]},
      closed_at: issue["closed_at"],
      points: issue_points(issue)
    }
  end
end
