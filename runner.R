# Load helper functions.
source("helpers-generic.R")

# Gather minimal data about this week.
week_num <- next_week_num()
week_year <- next_year()

# Week 1 is "bring your own data", let's deal with that specifically.
if (week_num == 1) {
  status_msg <- glue::glue(
    "It's week 1 of {week_year}, which means it's Bring Your Own Data Week!\n",
    "Ideas:",
    "{emoji::emoji('rewind')} A previous #TidyTuesday dataset (https://tidytues.day/{week_year - 1})",
    "{emoji::emoji('index pointing at the viewer')} Personal metadata (TV shows watched, music listened, #RStats written, etc)",
    "{emoji::emoji('question')} Whatever else you want to use!",
    "\n#r4ds #tidyverse #DataViz",
    .sep = "\n"
  )
  img_paths <- NULL
  alt_text <- NULL
} else {
  available_datasets <- tidytuesdayR::tt_datasets(week_year) |> 
    unclass() |> 
    tibble::as_tibble()
  
  # This if/else is somewhat backward, because it's easier to stop early and get
  # rid of the if.
  if (!(week_num %in% available_datasets$Week)) {
    stop("No data available!")
  }
  
  # Sort out the rest of the info that goes into social media posts.
  data_title <- available_datasets$Data[available_datasets$Week == week_num]
  week_date <- next_tuesday()
  
  # Download the images to the action runner.
  download.file(next_file("pic1.png"), "pic1.png", mode = "wb")
  download.file(next_file("pic2.png"), "pic2.png", mode = "wb")
  
  img_paths <- c(
    "tt_logo.png",
    "tt_rules.png",
    "pic1.png",
    "pic2.png"
  )
  
  # Try to get variables for the post.
  post_vars <- read_post_vars()
  alt_text <- c(
    paste(
      "Logo for the #TidyTuesday Project, it's the words TidyTuesday overlaying",
      "a black paint splash"    
    ),
    paste(
      "The data set comes from the source article or the source that the article",
      "credits. Be mindful that the data is what it is and Tidy Tuesday is",
      "designed to help you practice data visualization and basic data wrangling",
      "in R.\nThis is NOT about criticizing the original article or graph. Real",
      "people made the graphs, collected or acquired the data! Focus on the",
      "provided dataset, learning, and improving your techniques in R.\nThis is",
      "NOT about criticizing or tearing down your fellow #RStats practitioners",
      "or their code! Be supportive and kind to each other! Like other's posts",
      "and help promote the #RStats community!\nUse the hashtag #TidyTuesday on",
      "Twitter if you create your own version and would like to share",
      "it.\nInclude a picture of the visualisation.\nInclude a copy of the code",
      "used to create your visualization.\nFocus on improving your craft, even",
      "if you end up with something simple!\nGive credit to the original data",
      "source whenever possible."    
    )
  )
  
  status_msg <- glue::glue(
    "The @R4DSCommunity welcomes you to week {week_num} of #TidyTuesday!",
    " We're exploring {data_title}!\n\n", 
    "{emoji::emoji('folder')} https://tidytues.day/{week_year}/{week_date}" 
  )
  status_msg_end <- "\n\n#RStats #DataViz #PyData #tidyverse"
  
  if (length(post_vars)) {
    long_msg <- glue::glue(
      status_msg, 
      "\n{emoji::emoji('news')} {post_vars$article_link}"
    )
    # Subtract 16 because twitter doesn't count the https:// and everything else
    # allows for longer messages. And we have 2 of those now.
    if (nchar(long_msg) - 16 + nchar(status_msg_end) <= 280) {
      status_msg <- long_msg
    }
    alt_text <- c(
      alt_text,
      post_vars$pic1_alt,
      post_vars$pic2_alt
    )
  }
  
  status_msg <- glue::glue(status_msg, status_msg_end)
}

# Toot.
source("helpers-mastodon.R")
tt_toot(status_msg, img_paths, alt_text)

# LinkedIn.
source("helpers-linkedin.R")
tt_linkedin(status_msg)

# Tweet.
source("helpers-twitter.R")
tt_tweet(status_msg, img_paths, alt_text)

# Slack.
source("helpers-slack.R")
tt_slack(status_msg, status_msg_end, img_paths, alt_text)
