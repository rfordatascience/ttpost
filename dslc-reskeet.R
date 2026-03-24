source("helpers-bsky.R", local = TRUE)

bsky_result <- readRDS("bsky_result.rds")

if (attr(bsky_result, "week") != lubridate::week(lubridate::now())) {
  stop("The bsky result was not generated this week. Stopping.")
}

attr(bsky_result, "week") <- NULL

post_uri <- bsky_result$uri

bskyr::set_bluesky_user("dslc.io")
bskyr::set_bluesky_pass(Sys.getenv("BSKY_DSLC"))
auth <- bskyr::bs_auth(bskyr::get_bluesky_user(), bskyr::get_bluesky_pass(), NULL)

bskyr::bs_like(post_uri, auth = auth)

reskeet_msg <- paste(
  "It's #TidyTuesday y'all! Show us what you made on our Slack at https://dslc.io!",
  "#RStats #PyData #JuliaLang #RustLang #DataViz #DataScience #DataAnalytics #data #tidyverse #DataBS",
  sep = "\n"
)

result <- bskyr::bs_post(
  reskeet_msg,
  quote = post_uri,
  embed = FALSE,
  auth = auth
)

# Pin the reskeet to the DSLC profile
profile <- bskyr::bs_get_record(
  repo = auth$did,
  collection = "app.bsky.actor.profile",
  rkey = "self",
  auth = auth,
  clean = FALSE
)

profile$value$pinnedPost <- list(uri = result$uri, cid = result$cid)

httr2::request("https://bsky.social/xrpc/com.atproto.repo.putRecord") |>
  httr2::req_auth_bearer_token(auth$accessJwt) |>
  httr2::req_body_json(list(
    repo       = auth$did,
    collection = "app.bsky.actor.profile",
    rkey       = "self",
    record     = profile$value
  )) |>
  httr2::req_perform()
