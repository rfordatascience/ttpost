rtweet::rtweet_bot(
  api_key = Sys.getenv("TTBOT_API_KEY"),
  api_secret = Sys.getenv("TTBOT_API_SECRET"),
  access_token = Sys.getenv("TTBOT_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TTBOT_ACCESS_TOKEN_SECRET")
)
tweet_start_ts <- Sys.time()
rtweet::post_tweet(
  status = glue::glue(
    "This is another test tweet, sent at {tweet_start_ts}."
  )
)
