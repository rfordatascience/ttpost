source("helpers.R")

token <- rtweet::rtweet_bot(
  api_key = Sys.getenv("TTBOT_API_KEY"),
  api_secret = Sys.getenv("TTBOT_API_SECRET"),
  access_token = Sys.getenv("TTBOT_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TTBOT_ACCESS_TOKEN_SECRET")
)

next_tt_num <- next_week_num()
next_tt_year <- next_year()

available_datasets <- tidytuesdayR::tt_datasets(next_tt_year)

if (next_tt_num %in% available_datasets$Week) {
  tweet_start_ts <- Sys.time()
  rtweet::post_tweet(
    status = glue::glue(
      "This is another test tweet, sent at {tweet_start_ts}."
    ),
    token = token
  )
} else {
  stop("No data available!")
}


