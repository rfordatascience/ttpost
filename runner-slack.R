# Do the common tasks.
source("runner-shared.R", local = TRUE)

# Slack.
source("helpers-slack.R", local = TRUE)
tt_slack(status_msg, status_msg_end, img_paths, alt_text)
