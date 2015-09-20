defmodule IssuesLeaderboard.ThemeCreator do
  @api_key System.get_env("YOUTUBE_KEY")
  @url_base "https://www.googleapis.com/youtube/v3"
  @max_page_size 50

  def find_videos(query) do
    search_videos(query)
    |> video_ids
    |> get_videos
    |> filter_short_videos
  end

  defp search_videos(query) do
    get(@url_base <> "/search", %{
      part: "id",
      type: "video",
      maxResults: @max_page_size,
      videoDuration: "short",
      videoEmbeddable: "true",
      q: query
    }, 10)
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
           part: "id,snippet,contentDetails",
           maxResults: @max_page_size
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
         # 1-18 seconds in ISO 8601 duration
         Regex.match?(~r/PT([1-9]|1[0-8])S/, duration)
       end)
  end

  defp get(url, query) do
    get(url, query, 1)
  end
  defp get(url, query, num_pages) do
    get(url, query, num_pages, [], nil)
  end
  defp get(_url, _query, 0, results, _pageToken) do
    results
  end
  defp get(url, query, num_pages, results, pageToken) do
    url_query = query
    |> Map.merge(%{key: @api_key, pageToken: pageToken})
    |> URI.encode_query

    result = HTTPoison.get!("#{url}?#{url_query}").body |> Poison.decode!
    items = result["items"]
    get(url, query, num_pages - 1, results ++ items, result["nextPageToken"])
  end
end
