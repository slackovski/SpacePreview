# R script example
library(httr2)
library(dplyr)
library(ggplot2)

fetch_users <- function(base_url = "https://api.example.com") {
  req <- request(base_url) |>
    req_url_path("/users") |>
    req_headers(Accept = "application/json")

  resp <- req_perform(req)
  resp_body_json(resp, simplifyVector = TRUE)
}

summarise_users <- function(users_df) {
  users_df |>
    group_by(role) |>
    summarise(
      count      = n(),
      avg_id     = mean(id),
      .groups    = "drop"
    ) |>
    arrange(desc(count))
}

users <- fetch_users()
summary <- summarise_users(users)
print(summary)

ggplot(summary, aes(x = role, y = count, fill = role)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Users by Role", x = NULL, y = "Count") +
  theme_minimal()
