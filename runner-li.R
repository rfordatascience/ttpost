# Do the common tasks.
source("runner-shared.R", local = TRUE)
source("helpers-linkedin.R", local = TRUE)

# At least for now, we use the same image for every TT post on LinkedIn.
alt_text <- paste(
  "Logo for the #TidyTuesday Project. The words TidyTuesday overlaying",
  "a black paint splash"    
)

author_req <- li_base |> 
  httr2::req_url("https://api.linkedin.com/v2/me")
author_id <- li_perform(author_req) |> httr2::resp_body_json() |> _$id

author <- glue::glue("urn:li:person:{author_id}")

# The new LinkedIn API uses markdown, so escape _ so it isn't confused.
status_msg <- stringr::str_replace_all(
  status_msg,
  stringr::fixed("_"),
  "\\_"
)

if (
  length(metadata) && 
  length(metadata$credit$linkedin) && 
  !is.na(metadata$credit$linkedin) && 
  metadata$credit$linkedin != ""
) {
  li_credit <- stringr::str_replace(
    metadata$credit$linkedin,
    "https://www.linkedin.com/in/",
    "^@"
  )
  
  credit <- glue::glue(
    "Curator: {li_credit}"
  )
  if (length(credit)) {
    status_msg <- paste(credit, status_msg, sep = "\n")
  }
}

# We have more room, so include more info.
status_msg <- status_msg |> 
  paste(
    "\nNew to #TidyTuesday?",
    "Welcome to the weekly social data project. All are welcome!",
    "⬡ The event is organized by the Data Science Learning Community https://dslc.io",
    "⬡ For the latest datasets, follow DSLC on Mastodon or LinkedIn",
    sep = "\n"
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
     #content = list(
     #  media = list(
         # id = "urn:li:image:D5622AQEHKFmWxhSlJQ", # Owned by Jon
     #    id = "urn:li:image:D562CAQEXGJZvRPNQEQ", # Owned by Lydia
     #    altText = alt_text
     #  )
     #),
      lifecycleState = "PUBLISHED",
      isReshareDisabledByAuthor = FALSE
    )
  )

posted <- li_perform(li_post)

if (httr2::resp_status(posted) != 201) {
  stop("LinkedIn broke!")
}

post_id <- httr2::resp_header(posted, "x-linkedin-id")
attr(post_id, "week") <- lubridate::week(lubridate::now())
saveRDS(post_id, "li_post_id.rds")

