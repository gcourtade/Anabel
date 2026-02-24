# Use the official R-Shiny base image
FROM rocker/shiny-verse:latest

# Command to run the app directly from GitHub when the container starts
CMD ["R", "-e", "shiny::runGitHub('Anabel', 'gcourtade', host = '0.0.0.0', port = 3838)"]
