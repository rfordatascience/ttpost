# Do the common tasks.
source("runner-shared.R", local = TRUE)

# LinkedIn.

# Explicitly library httpuv so renv acknowledges that it's needed.
library(httpuv)
 
# At least for now, we use the same image for every TT post on LinkedIn.
alt_text <- paste(
  "Logo for the #TidyTuesday Project. The words TidyTuesday overlaying",
  "a black paint splash"    
)

author <- "urn:li:person:mBbHaQfQtg"

# The new LinkedIn API uses markdown, so escape _ so it isn't confused.
status_msg <- stringr::str_replace_all(
  status_msg,
  stringr::fixed("_"),
  "\\_"
)

# We have more room, so include more info.
status_msg <- status_msg |> 
  paste(
    "\nNew to #TidyTuesday?",
    "Welcome to the weekly social data project. All are welcome!",
    "⬡ The event is organized by the Data Science Learning Community (https://dslc.io).",
    "⬡ For the latest datasets, follow DSLC on Mastodon or LinkedIn",
    sep = "\n"
  )

li_client <- httr2::oauth_client(
  id = Sys.getenv("LI_CLIENT_ID"),
  token_url = "https://www.linkedin.com/oauth/v2/accessToken",
  secret = Sys.getenv("LI_CLIENT_SECRET"),
  auth = "header"
)

# To refresh the refresh, visit 
# https://www.linkedin.com/developers/tools/oauth/token-generator
# 
# TODO: Make this work with code.
# https://learn.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow?tabs=HTTPS1#step-2-request-an-authorization-code

li_base <- httr2::request("https://api.linkedin.com/rest") |> 
  httr2::req_oauth_refresh(
    client = li_client,
    refresh_token = Sys.getenv("LI_REFRESH_TOKEN"),
    scope = "r_basicprofile,r_emailaddress,r_liteprofile,r_organization_social,w_member_social,w_organization_social"
  ) |>
  httr2::req_headers(
    `Linkedin-Version` = "202306"
  )

li_post <- li_base |> 
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
          id = "urn:li:image:D5622AQEHKFmWxhSlJQ",
          altText = alt_text
        )
      ),
      lifecycleState = "PUBLISHED",
      isReshareDisabledByAuthor = FALSE
    )
  )

posted <- li_post |>
  # Sometimes it fails the first time or three. Still trying to figure out
  # *why*, but this seems to fix it.
  httr2::req_retry(
    # It fails for lack of auth. I think their server is catching up with the
    # refresh usage, maybe?
    is_transient = \(x) httr2::resp_status(x) == 401,
    max_tries = 10,
    backoff = ~ 3
  ) |> 
  httr2::req_perform()

if (httr2::resp_status(posted) != 201) {
  stop("LinkedIn broke!")
}
