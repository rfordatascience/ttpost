# Do the common tasks.
source("runner-shared.R", local = TRUE)

# Skeet.
source("helpers-bsky.R", local = TRUE)

bsky_msg_start <- stringr::str_replace(
  status_msg_start,
  "https://DSLC.io welcomes you",
  "@dslc.io welcomes you"
)

bsky_msg <- paste(bsky_msg_start, status_msg_end, sep = "\n")

if (nchar(article_msg) + nchar(bsky_msg) < 300) {
  bsky_msg_start <- paste(bsky_msg_start, article_msg, sep = "\n")
  bsky_msg <- paste(bsky_msg_start, status_msg_end, sep = "\n")
}

if (length(metadata$credit$bluesky)) {
  bsky_credit <- stringr::str_replace(
    metadata$credit$bluesky,
    "https://bsky.app/profile/",
    "@"
  )
  credit <- glue::glue("Curator: {bsky_credit}")
  maybe_msg <- paste(
    credit, bsky_msg, sep = "\n"
  )
  if (length(credit) && (nchar(maybe_msg) <= 300)) {
    bsky_msg <- maybe_msg
  }
}

bskyr::set_bluesky_user("jonthegeek.com")
bskyr::set_bluesky_pass(Sys.getenv("BSKY_APP_PASS"))
bskyr::bs_auth(bskyr::get_bluesky_user(), bskyr::get_bluesky_pass(), NULL)

result <- tt_skeet(bsky_msg, img_paths, alt_text)

attr(result, "week") <- lubridate::week(lubridate::now())
saveRDS(result, "bsky_result.rds")
