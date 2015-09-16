defmodule IssuesLeaderboard.Leaderboard do
  @interval 15_000

  def start(after_date) do
    spawn(fn -> run_and_schedule(after_date) end)
  end

  def run_and_schedule(after_date) do
    rankings = run(after_date)
    IssuesLeaderboard.Endpoint.broadcast! "boards:default", "rankings",
      %{rankings: rankings}
    :timer.sleep(@interval)
    run_and_schedule(after_date)
  end

  def run(after_date) do
    IssuesLeaderboard.IssuesSync.issues(after_date)
    |> issues_to_rankings
    |> apply_ranks
  end

  defp issues_to_rankings(user_issues) do
    user_issues
    |> Enum.group_by(&(&1[:assignee][:username]))
    |> Enum.map(&serialize_ranking/1)
    |> Enum.sort_by(fn %{total: total} -> total end)
    |> Enum.reverse
  end

  defp serialize_ranking({_username, issues}) do
    %{user: List.first(issues)[:assignee],
      issues: issues,
      total: Enum.map(issues, &(&1[:points])) |> Enum.sum}
  end

  defp apply_ranks(rankings) do
    rankings
    |> Enum.map(fn ranking ->
         rank = Enum.find_index(rankings, &(&1[:total] == ranking[:total])) + 1
         Map.put(ranking, :rank, rank)
       end)
  end
end
