# Job title database

`job-titles.txt` holds 71,748 cleaned, de-duplicated job titles; with the app's own preset roles that comes to 72,007 searchable jobs. The app embeds this list for its job search.

Source: [fluquid/find_job_titles](https://github.com/fluquid/find_job_titles), `titles_combined.txt.gz`. MIT License, Copyright (c) 2017 Johannes Ahlmann.
Cleaning: kept titles 3–60 characters long, turned "Teacher, Preschool" into "Preschool Teacher", and dropped case-insensitive duplicates.

Every title is mapped to one of the app's 38 fields by keyword. Titles with no match use the general interview format, and the AI still interviews as an expert in that exact title.
