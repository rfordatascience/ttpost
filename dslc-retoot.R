source("dslc-helpers-mastodon.R", local = TRUE)

tt_toot_jon <- get_jon_toot()

like_jon_toot(tt_toot_jon$id)

toot_content <- set_toot_content(tt_toot_jon)

rtoot::post_toot(status = toot_content)

dslc_toots <- get_dslc_toots()

pin_status(dslc_toots[["pinned"]], unpin = TRUE)
pin_status(dslc_toots[["unpinned"]])
