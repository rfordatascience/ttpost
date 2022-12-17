tt_tweet <- function(status_msg, img_paths, alt_text) {
  token <- rtweet::rtweet_bot(
    api_key = Sys.getenv("TTBOT_API_KEY"),
    api_secret = Sys.getenv("TTBOT_API_SECRET"),
    access_token = Sys.getenv("TTBOT_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TTBOT_ACCESS_TOKEN_SECRET")
  )
  
  rtweet::post_tweet(
    status = status_msg, 
    media = img_paths,
    media_alt_text = alt_text,
    token = token
  )
}
