# Issues Leaderboard

To start:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Examples

**Get Issues**
```elixir
after_date = "2015-09-14T05:00:00Z"
IssuesLeaderboard.IssuesSync.issues(after_date)
```

**Fetch and Broadcast issues at interval**
```elixir
after_date = "2015-09-14T05:00:00Z"
IssuesLeaderboard.Leaderboard.start(after_date)
```
