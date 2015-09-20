defmodule IssuesLeaderboard.IssuesSync do
  use Timex

  def issues(repo, after_date) do
    fetch_issues(repo, after_date) |> Enum.map(&serialize_issue/1)
  end

  defp client do
    Tentacat.Client.new(%{access_token: System.get_env("GITHUB_KEY") })
  end

  defp fetch_issues(repo, after_date) do
    Tentacat.get("repos/#{repo}/issues", client,
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
