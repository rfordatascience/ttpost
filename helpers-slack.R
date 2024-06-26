tt_slack <- function(status_msg, status_msg_end, img_paths, alt_text) {
  # We don't need the hashtags for Slack.
  dslc_msg <- stringr::str_replace(
    status_msg,
    "https://DSLC.io welcomes you",
    "<!here> Welcome"
  ) |> 
    stringr::str_remove_all(status_msg_end)
  
  posted <- slackcalls::post_slack(
    slack_method = "chat.postMessage",
    text = dslc_msg,
    channel = "C0106FDAE74" # chat-tidytuesday
  )
  
  if (!posted$ok) {
    stop("Slack broke!")
  }
  
  return(invisible(TRUE))
}
