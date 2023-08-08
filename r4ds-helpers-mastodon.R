Sys.setenv(RTOOT_DEFAULT_TOKEN = Sys.getenv("RTOOT_R4DS_TOKEN"))

get_jon_toot <- function() {
  jon_toot <- rtoot::get_account_statuses(
    id = "109245649177941364",
    hashtag = "#TidyTuesday",
    exclude_reblogs = TRUE,
    limit = 3
  ) |> 
    dplyr::filter(
      stringr::str_detect(
        content,
        stringr::fixed("welcomes you to week")
      )
    ) |> 
    head(1)
  
  jon_content <- jon_toot$content |> 
    rvest::read_html() |> 
    rvest::html_text2()
  
  return(
    list(
      content = jon_content,
      url = jon_toot$url,
      id = jon_toot$id
    )
  )
}

like_jon_toot <- function(id) {
  rtoot::post_status(
    id,
    "favourite",
    verbose = FALSE
  )
  rtoot::post_status(
    id,
    "reblog",
    verbose = FALSE
  )
  return(invisible(TRUE))
}

get_r4ds_toots <- function() {
  r4ds_toots <- rtoot::get_account_statuses(
    id = "109243727882736782",
    hashtag = "#TidyTuesday",
    exclude_reblogs = TRUE,
    limit = 3
  ) |> 
    dplyr::filter(
      stringr::str_starts(
        content, stringr::fixed(
          '<p>It&#39;s <a href=\"https://fosstodon.org/tags/TidyTuesday\"'
        )
      )
    ) |> 
    head(2) |> 
    dplyr::select(id, pinned) |> 
    dplyr::arrange(pinned)
  return(
    rlang::set_names(
      r4ds_toots$id,
      c("unpinned", )
    )
  )
}

set_toot_content <- function(tt_toot_jon) {
  toot_content <- glue::glue(
    "It's #TidyTuesday y'all! Show us what you made on our Slack at https://r4ds.io/join (find the #chat-tidytuesday channel)!",
    "RT @jonthegeek {tt_toot_jon$url}",
    "{tt_toot_jon$content}",
    .sep = "\n\n"
  )
  
  if (nchar(toot_content) > 500) {
    toot_content <- glue::glue(
      "It's #TidyTuesday y'all! Show us what you made on our Slack at https://r4ds.io/join (find the #chat-tidytuesday channel)!",
      "RT @jonthegeek {tt_toot_jon$url}",
      "#RStats #DataViz #PyData #tidyverse #r4ds",
      .sep = "\n\n"
    )
  }
  
  return(toot_content)
}

rtoot_token_from_envvar <- function(envvar = "RTOOT_R4DS_TOKEN") {
  rlang::set_names(
    as.list(strsplit(x = Sys.getenv(envvar), split = ";")[[1]]),
    c("bearer", "type", "instance")
  )
}

pin_status <- function(id, unpin = FALSE) {
  action <- dplyr::if_else(unpin, "unpin", "pin")
  
  token <- rtoot_token_from_envvar()
  path <- glue::glue(
    "https://{token$instance}/api/v1/statuses/{id}/{action}"
  )
  response <- httr2::request(path) |> 
    httr2::req_auth_bearer_token(token$bearer) |> 
    httr2::req_user_agent("ttpost (https://github.com/rfordatascience/ttpost)") |> 
    httr2::req_method("post") |> 
    httr2::req_perform()
  
  if (httr2::resp_status(response) == 200) {
    return(invisible(NULL))
  } else {
    return(response)
  }
}