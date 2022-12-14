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
