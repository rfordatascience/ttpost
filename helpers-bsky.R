# Reference base64enc so renv will install it.
library(base64enc)

tt_skeet <- function(status_msg, img_paths, alt_text) {
  result <- bskyr::bs_post(
    text = status_msg,
    images = img_paths,
    images_alt = alt_text
  )
  if (result$validation_status[[1]] != "valid") {
    stop("Bluesky broke!")
  }

  return(result)
}

bsky_nchar <- function(text) {
  # There's more to sort out here, but for now I know this much.
  text <- stringr::str_remove_all(text, "http(s?)://")
  nchar(text)
}
