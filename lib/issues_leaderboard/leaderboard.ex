defmodule IssuesLeaderboard.Leaderboard do
  use GenServer

  @interval 15_000

  # API

  def start_link(after_date) do
    spawn_link(fn -> run_and_schedule(after_date) end)
    {:ok, _pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Implementation

  def run_and_schedule(after_date) do
    rankings = run(after_date)
    leader = rankings |> List.first |> get_in([:user, :username])
    IO.puts "Leaderboard: Generated rankings. Current leader: #{leader}"

    IssuesLeaderboard.Endpoint.broadcast! "boards:default", "rankings",
      %{rankings: rankings}

    :timer.sleep(@interval)
    run_and_schedule(after_date)
  end

  def run(after_date) do
    IssuesLeaderboard.IssuesSync.issues(after_date)
    |> Stream.reject(fn issue -> is_nil(issue[:assignee][:username]) end)
    |> Stream.filter(fn issue -> issue[:points] > 0 end)
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
