# Do the common tasks.
source("runner-shared.R", local = TRUE)

# Tweet.
source("helpers-twitter.R", local = TRUE)
tt_tweet(status_msg, img_paths, alt_text)
