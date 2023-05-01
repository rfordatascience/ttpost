tt_linkedin <- function(status_msg) {
  # At least for now, we use the same image for every TT post on LinkedIn.
  alt_text <- paste(
    "Logo for the #TidyTuesday Project, it's the words TidyTuesday overlaying",
    "a black paint splash"    
  )

  author <- "urn:li:person:mBbHaQfQtg"

  # The new LinkedIn API uses markdown, so escape _ so it isn't confused.
  status_msg <- stringr::str_replace_all(
    status_msg,
    stringr::fixed("_"),
    "\\_"
  )
  
  # Link to R4DS in the LinkedIn format.
  status_msg <- stringr::str_replace(
    status_msg,
    "@R4DSCommunity",
    "@[R4DS Online Learning Community](urn:li:organization:65437630)"
  )
  
  # We have more room, so include more info.
  status_msg <- status_msg |> 
    paste(
      "\nNew to #TidyTuesday?",
      "Welcome to the weekly social data project in R. All are welcome!",
      "⬡ The event is organized by the R4DS Online Learning Community.",
      "⬡ For the latest datasets, follow R4DS on Twitter, Mastodon, LinkedIn, or Posit Community https://community.rstudio.com/c/tidytuesday/65",
      sep = "\n"
    )
  
  li_client <- httr2::oauth_client(
    id = Sys.getenv("LI_CLIENT_ID"),
    token_url = "https://www.linkedin.com/oauth/v2/accessToken",
    secret = Sys.getenv("LI_CLIENT_SECRET"),
    auth = "header"
  )
  
  updated_token <- httr2::oauth_flow_refresh(
    li_client,
    refresh_token = Sys.getenv("LI_REFRESH_TOKEN")
  )
  
  li_base <- httr2::request("https://api.linkedin.com/v2") |> 
    httr2::req_auth_bearer_token(updated_token$access_token) |>
    httr2::req_headers(
      `X-Restli-Protocol-Version` = "2.0.0"
    )
  
  posted <- li_base |> 
    httr2::req_url_path_append("posts") |> 
    httr2::req_body_json(
      list(
        author = author,
        commentary = status_msg,
        visibility = "PUBLIC",
        distribution = list(
          feedDistribution = "MAIN_FEED",
          targetEntities = list(),
          thirdPartyDistributionChannels = list()
        ),
        content = list(
          media = list(
            id = "urn:li:image:C5622AQET2DqAfePIaw",
            altText = alt_text
          )
        ),
        lifecycleState = "PUBLISHED",
        isReshareDisabledByAuthor = FALSE
      )
    ) |> 
    httr2::req_perform()
  
  if (httr2::resp_status(posted) != 201) {
    stop("LinkedIn broke!")
  }
  
  return(invisible(TRUE))
}
