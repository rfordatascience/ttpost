source("helpers-linkedin.R", local = TRUE)

# Load the li_post_id artifact and verify that it was generated this week.
li_post_id <- readRDS("li_post_id.rds")

if (attr(li_post_id, "week") != lubridate::week(lubridate::now())) {
  stop("The LinkedIn post ID was not generated this week. Stopping.")
}

attr(li_post_id, "week") <- NULL

repost_msg <- "It's #TidyTuesday y'all! Show us what you made on our Slack at https://dslc.io/ -- find the chat-tidytuesday channel!\n\n#RStats #PyData #JuliaLang #DataViz #DataScience #DataAnalytics #data #tidyverse #R4DS"
author_dslc <- "urn:li:organization:65437630"

reshare_req <- li_base |> 
  httr2::req_url_path_append("posts") |> 
  httr2::req_body_json(
    list(
      author = author_dslc,
      commentary = repost_msg,
      visibility = "PUBLIC",
      distribution = list(
        feedDistribution = "MAIN_FEED",
        targetEntities = list(),
        thirdPartyDistributionChannels = list()
      ),
      lifecycleState = "PUBLISHED",
      isReshareDisabledByAuthor = FALSE,
      reshareContext = list(
        parent = li_post_id
      )
    )
  )

reshared <- li_perform(reshare_req)

if (httr2::resp_status(reshared) != 201) {
  stop("LinkedIn broke!")
}
