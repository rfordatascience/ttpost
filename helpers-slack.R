tt_slack <- function(status_msg, status_msg_end, img_paths, alt_text) {
  # We don't need the hashtags for Slack.
  r4ds_msg <- stringr::str_replace(
    status_msg,
    "The @R4DSCommunity welcomes you",
    "<!here> Welcome"
  ) |> 
    stringr::str_remove_all(status_msg_end)
  
  posted <- slackcalls::post_slack(
    slack_method = "chat.postMessage",
    text = r4ds_msg,
    channel = "C0106FDAE74" # chat-tidytuesday
  )
  
  if (!posted$ok) {
    stop("Slack broke!")
  }
  
  return(invisible(TRUE))
}
