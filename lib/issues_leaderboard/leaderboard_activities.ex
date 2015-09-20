defmodule IssuesLeaderboard.LeaderboardActivities do
  # Diffs to identify
  # - [X] User scored points
  # - [ ] Users tied
  # - [ ] User beat tie
  # - [ ] User entered rankings

  @doc """
  Generates activities by diffing two sets of rankings.

  Examples:
  iex> IssuesLeaderboard.LeaderboardActivities.activities(
         [%{user: %{username: "mrwade"}, total: 4}],
         [%{user: %{username: "mrwade"}, total: 6}])
  [{:points_scored, %{user: %{username: "mrwade", scored: 2}}}
  """
  def activities(a, b) do
    users = users_lookup(a, b)
    points_scored(a, b, users) |> serialize
  end

  def serialize(activities) do
    Enum.map(activities, fn {type, data} -> Dict.put(data, :type, type) end)
  end

  @doc """
  Generates mapping from rankings to look up user info by username.

  Examples:
  iex> IssuesLeaderboard.LeaderboardActivities.users_lookup(
         [%{user: %{username: "mrwade"}, total: 4}],
         [%{user: %{username: "tfausak"}, total: 6}])
  %{"mrwade" => %{username: "mrwade"}, "tfausak" => %{username: "tfausak"}}
  """
  def users_lookup(a, b) do
    gen_map = fn r -> {r[:user][:username], r[:user]} end
    a_lookup = Enum.map(a, gen_map) |> Enum.into(Map.new)
    b_lookup = Enum.map(b, gen_map) |> Enum.into(Map.new)
    Map.merge(a_lookup, b_lookup)
  end

  def points_scored(a, b, users) do
    a_usernames = Enum.map(a, fn r -> r[:user][:username] end)
    a_totals = total_points_by_user(a)
    b_totals = total_points_by_user(b)

    Set.difference(
      Enum.into(b_totals, HashSet.new),
      Enum.into(a_totals, HashSet.new))
    |> Stream.filter(fn {username, _} -> Enum.member?(a_usernames, username) end)
    |> Enum.map(fn {username, b_total} ->
         {:points_scored, %{
            user: users[username],
            scored: b_total - a_totals[username]}}
       end)
  end
  defp total_points_by_user(rankings) do
    Enum.map(rankings, fn ranking ->
      {ranking[:user][:username], ranking[:total]} end)
    |> Enum.into(Map.new)
  end
end
