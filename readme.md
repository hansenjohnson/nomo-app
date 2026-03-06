# NoMo App
R Shiny application for displaying real-time noise data from a NOMO unit

## Summary
This web application, built using the R Shiny package, serves to display data from our custom-made NOise MOnitors (NOMOs). See the nomo repository (https://github.com/hansenjohnson/nomo) for more details and source code.

## Data processing
Currently, the NOMO systems send noise data (via cell) at regular intervals to `data/raw/{NOMO-ID}`. The shell script `src/move_noise_data.sh` looks for new data files, moves them to the correct deployment directory, then runs `r/proc_noise.R` to process the noise data. It is run in a cronjob every 15 minutes.

## To do
- Password protection
- Allow user to define deployments and update notes
    - Use an interactive table that reads/writes to a CSV on the server
    - Use this to assign a name, start and end time, and notes to each deployment
    - On the back end, do not aggregate data into deployment folders but keep it all pooled. Assign deployment IDs in the app.
- Add time slider to adjust date/time range
- Generalize to multiple NOMOs

## Project organization
`app.R` = source code for shiny application  
`src` = shell scripts for data operations  
`r` = R scripts for data processing  
`data` = noise data  

