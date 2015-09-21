defmodule IssuesLeaderboard.LeaderboardActivities do
  # Diffs to identify
  # - [X] User scored points
  # - [X] User lost points
  # - [ ] Users tied
  # - [ ] User beat tie
  # - [ ] User entered rankings
  # - [ ] New user in lead

  @doc """
  Generates activities by diffing two sets of rankings.

  Examples:
  iex> IssuesLeaderboard.LeaderboardActivities.activities(
         [%{user: %{username: "mrwade"}, total: 4}],
         [%{user: %{username: "mrwade"}, total: 6}])
  [{:points_scored, %{user: %{username: "mrwade", points: 2}}}
  """
  def activities(a, b) do
    users = users_lookup(a, b)
    points_changed(a, b, users) |> serialize
  end

  def serialize(activities) do
    Enum.map(activities, fn {type, data, video} ->
      Map.merge(data, %{type: type, video: video})
    end)
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

  @points_lost_videos [
    "https://www.youtube.com/watch?v=yJxCdh1Ps48", # sad trombone
    "https://www.youtube.com/watch?v=YzE4ILFgHzo"  # Price is Right losing horn
  ]

  def points_changed(a, b, users) do
    a_usernames = Enum.map(a, fn r -> r[:user][:username] end)
    a_totals = total_points_by_user(a)
    b_totals = total_points_by_user(b)

    map_diff(b_totals, a_totals)
    |> Enum.map(fn {username, b_total} ->
         points_change = b_total - (a_totals[username] || 0)
         data = %{user: users[username], points: abs(points_change)}
         if points_change > 0 do
           {:points_scored,
            Dict.put(data, :message,
              "#{username} scored #{pluralize(abs(points_change), "point")}"),
            pick_random(IssuesLeaderboard.ThemeCreator.get_video_urls)}
         else
           {:points_lost,
            Dict.put(data, :message,
              "#{username} lost #{pluralize(abs(points_change), "point")} :-("),
            pick_random(@points_lost_videos)}
         end
       end)
  end

  defp map_diff(a, b) do
    Set.difference(Enum.into(a, HashSet.new), Enum.into(b, HashSet.new))
  end

  defp pluralize(number, singular) do
    str = to_string(number) <> " " <> singular
    if number != 1 do
      str <> "s"
    else
      str
    end
  end

  defp pick_random(list) do
    Enum.at(list, :random.uniform(length(list))-1)
  end

  defp total_points_by_user(rankings) do
    Enum.map(rankings, fn ranking ->
      {ranking[:user][:username], ranking[:total]} end)
    |> Enum.into(Map.new)
  end
end
