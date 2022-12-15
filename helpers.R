# Inspired by Thomas Mock's tidytuesdaymeta package.

next_tuesday <- function() {
  todays_date <- lubridate::today(tzone = "America/New_York")
  # Tuesday is 3. How many days are we before Tuesday?
  diff_tuesday <- 3 - lubridate::wday(
    todays_date,
    week_start = 7 # Code explicitly to avoid strangeness.
  )
  if (diff_tuesday < 0) {
    diff_tuesday <- diff_tuesday + 7
  }
  return(todays_date + diff_tuesday)
}

next_week_num <- function() {
  week_date <- next_tuesday()
  year <- lubridate::year(week_date)
  jan_1st <- paste0(year, "0101")
  jan_1st <- lubridate::ymd(jan_1st)
  week_num <- as.numeric((week_date - jan_1st))/7 + 1
  return(round(week_num))
}

next_year <- function() {
  week_date <- next_tuesday()
  year <- lubridate::year(week_date)
  return(year)
}

read_tweet_vars <- function() {
  tweet_vars_url <- next_file("tweet_vars.json")
  resp <- httr::GET(tweet_vars_url)
  if (httr::status_code(resp) == 200) {
    return(httr::content(resp, type = "application/json"))
  } else {
    return(NULL)
  }
}

next_dir <- function() {
  return(
    file.path(
      "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data",
      next_year(),
      next_tuesday()
    )
  )
}

next_file <- function(filename) {
  return(
    file.path(
      next_dir(),
      filename
    )
  )
}

tt_tweet <- function(data_title) {
  week_num <- next_week_num()
  week_date <- next_tuesday()
  tues_year <- next_year()
  
  tweet_vars <- read_tweet_vars()
  alt_add <- NULL
  
  if (length(tweet_vars)) {
    status_msg <- glue::glue(
      "The @R4DScommunity welcomes you to week {week_num} of #TidyTuesday!",
      " We're exploring {data_title}!\n\n", 
      emoji::emoji("folder"), " http://bit.ly/tidyreadme\n", 
      emoji::emoji("news"), " {tweet_vars$article_link}\n", 
      "\n#r4ds #tidyverse #RStats #DataViz",
    )
    alt_add <- c(
      tweet_vars$pic1_alt,
      tweet_vars$pic2_alt
    )
  } else {
    status_msg <- glue::glue(
      "The @R4DScommunity welcomes you to week {week_num} of #TidyTuesday!",
      " We're exploring {data_title}!\n\n", 
      emoji::emoji("folder"), " http://bit.ly/tidyreadme\n", 
      "\n#r4ds #tidyverse #RStats #DataViz",
    )
  }
  
  token <- rtweet::rtweet_bot(
    api_key = Sys.getenv("TTBOT_API_KEY"),
    api_secret = Sys.getenv("TTBOT_API_SECRET"),
    access_token = Sys.getenv("TTBOT_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TTBOT_ACCESS_TOKEN_SECRET")
  )
  
  download.file(next_file("pic1.png"), "pic1.png", mode = "wb")
  download.file(next_file("pic2.png"), "pic2.png", mode = "wb")
  
  rtweet::post_tweet(
    status = status_msg, 
    media = c(
      "tt_logo.png",
      "tt_rules.png",
      "pic1.png",
      "pic2.png"
    ),
    media_alt_text = c(
      "Logo for the #TidyTuesday Project, it's the words TidyTuesday overlaying a black paint splash",
      "The data set comes from the source article or the source that the article credits. Be mindful that the data is what it is and Tidy Tuesday is designed to help you practice data visualization and basic data wrangling in R.\nThis is NOT about criticizing the original article or graph. Real people made the graphs, collected or acquired the data! Focus on the provided dataset, learning, and improving your techniques in R.\nThis is NOT about criticizing or tearing down your fellow #RStats practitioners or their code! Be supportive and kind to each other! Like other's posts and help promote the #RStats community!\nUse the hashtag #TidyTuesday on Twitter if you create your own version and would like to share it.\nInclude a picture of the visualisation.\nInclude a copy of the code used to create your visualization.\nFocus on improving your craft, even if you end up with something simple!\nGive credit to the original data source whenever possible.",
      alt_add
    ),
    token = token
  )
}