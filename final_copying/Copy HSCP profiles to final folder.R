# Copy Finalised HSCP Profiles from development area to HSCP specific folders
# This should be ran after the LPs have been completed and checked.
# Update the 'year' below, then run all the code.
# Run time: approx 5 min.

library(fs)
library(dplyr)
library(tidyr)
library(stringr)

# Update the year as needed. The directory will be named '{year} Final Profiles'
year <- "2025-April"

# Set top level file path
lp_path <- path(
  "/conf/LIST_analytics/West Hub/02 - Scaled Up Work/RMarkdown/Locality Profiles"
)

# Set paths for the existing / new locations of the profiles
output_dir <- path(lp_path, "Master RMarkdown Document & Render Code", "Output")
# The directory will be created automatically.
final_dir <- path(lp_path, "Final Profiles", str_glue("{year} Final Profiles"))

# Source in functions code
source("Master RMarkdown Document & Render Code/Global Script.R")

# Get the HSCP list
hscp_lookup <- read_in_localities() |>
  distinct(hscp2019name)

# Create a dataframe with some details about the files
profile_lookup <- tibble(
  path = dir_ls(path = output_dir, glob = "* - HSCP Profile.docx$"),
  file_name = path_file(path),
  hscp = str_extract(
    string = file_name,
    # Regular expresion, the brackets create a 'capture group'
    pattern = "^([A-Z].+?) - HSCP Profile.docx$",
    # We only want 'group 1' i.e. the bit in the brackets
    group = 1
  )
) |>
  # Drop any rows which didn't match a hscp (usually temp files etc.)
  drop_na(hscp)
# Add columns for the new directory (HSCP name) and the new path
mutate(
  new_dir = path(final_dir, hscp),
  new_path = path(new_dir, file_name)
)

# Create the new directories (if needed)
# Set the permissions correctly so we can edit the files if needed
dir_create(unique(pull(profile_lookup, new_dir)), mode = "ug=rwx,o=rx")

# Copy files to the relevant new directory
file_copy(
  path = pull(profile_lookup, path),
  new_path = pull(profile_lookup, new_path)
)
