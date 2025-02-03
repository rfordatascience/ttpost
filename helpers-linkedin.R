# Explicitly library httpuv so renv acknowledges that it's needed.
library(httpuv)

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

# Automatically set the LinkedIn API version to 2 months ago since they
# constantly change that without changing core features.
li_version_date <- lubridate::rollback(lubridate::today())

li_version <- paste0(
  lubridate::year(li_version_date), 
  stringr::str_pad(lubridate::month(li_version_date), 2, pad = "0")
)

li_base <- httr2::request("https://api.linkedin.com/rest") |> 
  httr2::req_oauth_refresh(
    client = li_client,
    refresh_token = Sys.getenv("LI_REFRESH_TOKEN"),
    scope = "r_basicprofile,r_emailaddress,r_liteprofile,r_member_social,r_organization_social,w_member_social,w_organization_social"
  ) |>
  httr2::req_headers(
    `Linkedin-Version` = li_version
  )

li_perform <- function(post_req) {
  post_req |> 
    httr2::req_retry(
      # It fails for lack of auth. I think their server is catching up with the
      # refresh usage, maybe?
      is_transient = \(x) httr2::resp_status(x) %in% c(401, 403, 425, 429),
      max_tries = 10,
      backoff = ~ 3
    ) |> 
    httr2::req_perform()
}
