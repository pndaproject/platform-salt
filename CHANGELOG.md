# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]
- PNDA-2142: Allow subnet IP ranges to be specified in pnda_env.yam and used as parameters to the cloud formation templates
- PNDA-2142: Allow any parameters to be passed through to the cloud formation templates, two settings have changed their names because they are now directly passed through - AWS_IMAGE_ID > imageId and AWS_ACCESS_WHITELIST > whitelistSshAccess. Update these in pnda_env.yaml otherwise the default value in the cloud formation template will be used.

## [1.0.0] 2016-10-21
### Added
- PNDA-2113: Pico flavor for small footprint clusters suitable for development or learning
- PNDA-2266: Save provisioning logs on the cloud instances in the /home/ubuntu folder
- PNDA-2275: '-b' branch CLI parameter to select a branch of platform-salt to use
- PNDA-2276: Allow a local copy of platform-salt to be used instead of a git URL to clone
- PNDA-2159: Additional .run log file saved in cli/logs

### Changed
- PNDA-2325: Use single pnda_env.yaml file instead of client_env.sh and pnda_env.sh
- PNDA-2272: Move to Salt 2015.8.11 in order to get the fix on orchestrate #33467

### Fixed
- PNDA-2333: Allow multiple clusters to be created in parallel from the same clone of pnda-aws-templates

## [0.1.0] 2016-09-07
### First version
- Resources for launching PNDA on AWS
