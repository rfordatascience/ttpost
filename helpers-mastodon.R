tt_toot <- function(status_msg, img_paths, alt_text) {
  rtoot::post_toot(
    status = status_msg,
    media = img_paths,
    alt_text = alt_text
  )
}
