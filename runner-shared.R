# Load helper functions.
source("helpers-generic.R")

# Gather minimal data about this week.
week_num <- next_week_num()
week_year <- next_year()

call_to_action <- "Submit a dataset! https://github.com/rfordatascience/tidytuesday/blob/master/.github/CONTRIBUTING.md"

# Week 1 is "bring your own data", let's deal with that specifically.
if (week_num == 1) {
  status_msg <- glue::glue(
    "It's week 1 of {week_year}, which means it's Bring Your Own Data Week!\n",
    "Ideas:",
    "{emoji::emoji('rewind')} A previous #TidyTuesday dataset (https://tidytues.day/{week_year - 1})",
    "{emoji::emoji('index pointing at the viewer')} Personal metadata (TV shows watched, music listened, #RStats written, etc)",
    "{emoji::emoji('question')} Whatever else you want to use!",
    paste0("\n", call_to_action),
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
  metadata <- read_post_vars()
  data_title <- metadata$title
  week_date <- next_tuesday()
  
  # Download the images to the action runner.
  img_files <- metadata$images |> purrr::map_chr("file")
  img_alts <- metadata$images |> purrr::map_chr("alt")
  purrr::walk(
    img_files,
    \(image) {
      download.file(next_file(image), image, mode = "wb")
    }
  )
  
  img_paths <- c(
    "tt_logo.png",
    "tt_rules.png",
    img_files
  )
  
  alt_text <- c(
    paste(
      "Logo for the #TidyTuesday Project. The words TidyTuesday overlaying a",
      "black paint splash"    
    ),
    paste(
      "TidyTuesday is a weekly social data project. All are welcome to", 
      "participate! Please remember to share the code used to generate your", 
      "results!\nTidyTuesday is organized by the Data Science Learning", 
      "Community. Join our Slack for free online help with R and other", 
      "data-related topics, or to participate in a data-related book club!\n\n", 
      "How to Participate\nData is posted to social media every Monday", 
      "morning. Follow the instructions in the new post for how to download", 
      "the data.\nExplore the data, watching out for interesting", 
      "relationships. We would like to emphasize that you should not draw", 
      "conclusions about causation in the data.\nCreate a visualization, a", 
      "model, a shiny app, or some other piece of data-science-related output,", 
      "using R or another programming language.\nShare your output and the", 
      "code used to generate it on social media with the #TidyTuesday hashtag."
    )
  )
  
  status_msg <- glue::glue(
    "https://DSLC.io welcomes you to week {week_num} of #TidyTuesday!",
    " We're exploring {data_title}!\n\n", 
    "{emoji::emoji('folder')} https://tidytues.day/{week_year}/{week_date}" 
  )
  status_msg_end <- paste(
    "\n",
    call_to_action,
    "\n#RStats #PyData #JuliaLang #DataViz #tidyverse #r4ds",
    sep = "\n"
  )
  
  if (length(metadata)) {
    long_msg <- glue::glue(
      status_msg, 
      "\n{emoji::emoji('news')} {metadata$article$url}"
    )
    if (nchar(long_msg) + nchar(status_msg_end) <= 500) {
      status_msg <- long_msg
    }
    alt_text <- c(
      alt_text,
      img_alts
    )
  }
  
  status_msg <- glue::glue(status_msg, status_msg_end)
}
