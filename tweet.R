source("helpers.R")

next_tt_num <- next_week_num()
next_tt_year <- next_year()

available_datasets <- tidytuesdayR::tt_datasets(next_tt_year) |> 
  unclass() |> 
  tibble::as_tibble()

if (next_tt_num %in% available_datasets$Week) {
  data_title <- available_datasets$Data[available_datasets$Week == next_tt_num]
  
  tt_tweet(data_title)
} else {
  stop("No data available!")
}


