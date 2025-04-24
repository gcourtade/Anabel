# Copyright (C) 2025  Stefan Kraemer
#   
#   This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
# Edited 24.04.25 Gaston Courtade for shinyapps.io compatibility
#
get_local_package_version <- function(package_name){
  as.character(packageVersion(package_name))
}

check_and_update_package_from_cran <- function(package_name, local_version){
  available_pkgs <- available.packages()
  if (package_name %in% rownames(available_pkgs)) {
    cran_version <- available_pkgs[package_name, "Version"]
    if (package_version(cran_version) > package_version(local_version)) {
      message(paste0("Updating ", package_name, " from CRAN (", local_version, " → ", cran_version, ")"))
      install.packages(package_name, dependencies = TRUE)
    }
  }
}

check_and_update_package_from_github <- function(github_repo, package_name, local_version){
  github_release <- remotes::parse_github_repo_spec(github_repo)
  gh_user <- github_release$username
  gh_repo <- github_release$repo
  
  release_data <- httr::GET(paste0("https://api.github.com/repos/", gh_user, "/", gh_repo, "/releases/latest"))
  
  if (httr::status_code(release_data) == 200) {
    release_info <- httr::content(release_data)
    github_version <- gsub("^v", "", release_info$tag_name)
    if (package_version(github_version) > package_version(local_version)) {
      message(paste0("Updating ", package_name, " from GitHub (", local_version, " → ", github_version, ")"))
      devtools::install_github(github_repo)
    }
  } else {
    message("Could not retrieve GitHub release information for ", package_name)
  }
}

check_and_install_packages <- function(list_of_packages){
  new.packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
  if (length(new.packages)) {
    message("Installing missing packages: ", paste(new.packages, collapse = ", "))
    install.packages(new.packages, dependencies = TRUE)
  }

  # Ensure 'anabel' is installed from GitHub if not available on CRAN
  if (!"anabel" %in% installed.packages()[,"Package"]) {
    devtools::install_github("SKscience/anabel")
  }

  # Update 'anabel' if needed
  local_version <- get_local_package_version("anabel")
  check_and_update_package_from_cran("anabel", local_version)
  local_version <- get_local_package_version("anabel")
  check_and_update_package_from_github("SKscience/anabel_backend", "anabel", local_version)
}

load_all_packages <- function(list_of_packages){
  lapply(setdiff(list_of_packages, "remotes"), library, character.only = TRUE)
}
