# objective: how to update R and r packages

# reference: https://www.linkedin.com/pulse/3-methods-update-r-rstudio-windows-mac-woratana-ngarmtrakulchol/

# step 1 download and install R manually. https://www.r-project.org/

# step 2 move all folders from your old R version to new R version.
# /Library/Frameworks/R.framework/Versions/x.xx/Resources/library

# step 3 Update the moved packages
update.packages(checkBuilt = TRUE)

# step 4 check status
version
packageStatus()