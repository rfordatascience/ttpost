tt_toot <- function(status_msg, img_paths, alt_text) {
  i <- 0L
  status_code <- 0L
  while (status_code != 200L && i < 5L) {
    res <- rtoot::post_toot(
      status = status_msg,
      media = img_paths,
      alt_text = alt_text
    )
    status_code <- res$status_code
    i <- i + 1L
  }
  if (status_code != 200L) {
    stop("Mastodon broke!")
  }
  
  return(res)
}
