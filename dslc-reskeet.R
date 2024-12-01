source("helpers-bsky.R", local = TRUE)

bsky_result <- readRDS("bsky_result.rds")

if (attr(bsky_result, "week") != lubridate::week(lubridate::now())) {
  stop("The bsky result was not generated this week. Stopping.")
}

attr(bsky_result, "week") <- NULL

post_uri <- bsky_result$uri

bskyr::set_bluesky_user("dslc.io")
bskyr::set_bluesky_pass(Sys.getenv("BSKY_DSLC"))
bskyr::bs_auth(bskyr::get_bluesky_user(), bskyr::get_bluesky_pass(), NULL)

bskyr::bs_like(post_uri)

reskeet_msg <- paste(
  "It's #TidyTuesday y'all! Show us what you made on our Slack at https://dslc.io!",
  "#RStats #PyData #JuliaLang #RustLang #DataViz #DataScience #DataAnalytics #data #tidyverse #DataBS",
  sep = "\n"
)

result <- bskyr::bs_post(
  reskeet_msg,
  quote = post_uri
)
