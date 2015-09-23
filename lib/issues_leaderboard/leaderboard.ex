defmodule IssuesLeaderboard.Leaderboard do
  require Logger
  use GenServer

  @interval 15_000

  # API

  def start_link(%BoardConfig{} = config) do
    spawn_link(fn -> run_and_schedule(config) end)
    {:ok, _pid} = Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get_rankings do
    Agent.get(__MODULE__, &(&1))
  end

  # Implementation

  defp set_rankings(rankings) do
    Agent.update(__MODULE__, fn _ -> rankings end)
  end

  defp run_and_schedule(%BoardConfig{} = config) do
    new_rankings = run(config)
    # leader = new_rankings |> List.first |> get_in([:user, :username])
    # Logger.info("Leaderboard: Generated rankings. Current leader: #{leader}")

    old_rankings = get_rankings
    if is_nil(old_rankings) do
      activities = nil
    else
      activities = IssuesLeaderboard.LeaderboardActivities.activities(
        old_rankings, new_rankings)
    end
    set_rankings(new_rankings)

    IssuesLeaderboard.Endpoint.broadcast! "boards:default", "update",
      %{activities: activities, rankings: new_rankings}

    :timer.sleep(@interval)
    run_and_schedule(config)
  end

  def run(%BoardConfig{} = config) do
    IssuesLeaderboard.IssuesSync.issues(config)
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
