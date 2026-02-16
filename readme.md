# NoMo App
R Shiny application for displaying real-time noise data from a NOMO unit

## Summary
This web application, built using the R Shiny package, serves to display data from our custom-made NOise MOnitors (NOMOs). See the nomo repository (https://github.com/hansenjohnson/nomo) for more details and source code.

## Data processing
Currently, the NOMO systems send noise data (via cell) at regular intervals to `data/raw/{NOMO-ID}`. The shell script `src/move_noise_data.sh` looks for new data files, then moves them to the correct deployment directory. It is run in a cronjob every 2 minutes.

## To do
- Password protection
- Allow user to define deployments and update notes

## Project organization
`app.R` = source code for shiny application  
`src` = shell scripts for data operations  
`data` = noise data  

