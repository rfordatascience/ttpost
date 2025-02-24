# Do the common tasks.
source("runner-shared.R", local = TRUE)

# Toot.
source("helpers-mastodon.R", local = TRUE)

if (length(metadata) && length(metadata$credit$mastodon)) {
  credit <- glue::glue(
    "Curator: {metadata$credit$mastodon}"
  )
  if (length(credit) && (nchar(status_msg, "bytes") + nchar(credit, "bytes") < 500)) {
    status_msg <- paste(credit, status_msg, sep = "\n")
  }
}

if (length(img_paths) > 4) {
  img_paths <- setdiff(img_paths, img_paths[[2]])
  alt_text <- setdiff(alt_text, alt_text[[2]])
  img_paths <- img_paths[1:4]
  alt_text <- alt_text[1:4]
}

tt_toot(status_msg, img_paths, alt_text)
