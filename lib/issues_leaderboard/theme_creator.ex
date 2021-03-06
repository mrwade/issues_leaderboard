defmodule IssuesLeaderboard.ThemeCreator do
  require Logger

  @url_base "https://www.googleapis.com/youtube/v3"
  @max_page_size 50

  # API

  def start_link(query) do
    {:ok, _pid} = Agent.start_link(fn -> find_videos(query) end, name: __MODULE__)
  end

  def get_videos, do: Agent.get(__MODULE__, &(&1))

  def get_video_urls, do: Enum.map(get_videos, &(&1[:url]))

  # Implementation

  def find_videos(query) do
    videos = search_videos(query)
    |> video_ids
    |> get_videos
    |> filter_short_videos
    |> Enum.map(&serialize/1)

    Logger.info "ThemeCreator: Fetched #{length(videos)} videos for \"#{query}\""
    videos
  end

  defp search_videos(query) do
    get(@url_base <> "/search", %{
      part: "id",
      type: "video",
      videoDuration: "short",
      videoEmbeddable: "true",
      q: query
    }, 500)
  end

  defp video_ids(api_result) do
    api_result
    |> Enum.map(fn %{"id" => %{"videoId" => video_id}} -> video_id end)
  end

  defp get_videos(video_ids) do
    video_ids
    |> in_groups_of(@max_page_size)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(fn ids ->
         get(@url_base <> "/videos", %{
           id: Enum.join(ids, ","),
           part: "id,snippet,contentDetails"
         })
       end)
  end

  defp in_groups_of(items, size) do
    in_groups_of(items, size, [])
  end
  defp in_groups_of([], _size, groups) do
    groups
  end
  defp in_groups_of(items, size, groups) do
    {group, tail} = Enum.split(items, size)
    in_groups_of(tail, size, groups ++ [group])
  end

  defp filter_short_videos(videos) do
    videos
    |> Enum.filter(fn %{"contentDetails" => %{"duration" => duration}} ->
         # 1-30 seconds in ISO 8601 duration
         Regex.match?(~r/PT([1-9]|1[0-9]|2[0-9]|30)S/, duration)
       end)
  end

  defp serialize(video) do
    %{
      url: "https://www.youtube.com/watch?v=#{video["id"]}"
    }
  end

  defp get(url, query, num_results \\ @max_page_size) do
    get(url, query, num_results, [], nil)
  end
  defp get(_url, _query, 0, results, _pageToken) do
    results
  end
  defp get(url, query, num_results, results, pageToken) when num_results > 0 do
    maxResults = Enum.min([num_results, @max_page_size])
    default_query = %{
      key: System.get_env("YOUTUBE_KEY"),
      maxResults: maxResults,
      pageToken: pageToken}

    url_query = query
    |> Map.merge(default_query)
    |> URI.encode_query
    result = HTTPoison.get!("#{url}?#{url_query}").body |> Poison.decode!

    get(url, query, num_results - maxResults, results ++ result["items"],
      result["nextPageToken"])
  end
end
