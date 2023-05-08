# Do the common tasks.
source("runner-shared.R", local = TRUE)

# Toot.
source("helpers-mastodon.R", local = TRUE)
tt_toot(status_msg, img_paths, alt_text)
