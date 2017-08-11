# Change Log
All notable changes to this project will be documented in this file.

## Unreleased
### Added
- PNDA-2955: Add pnda_env.yaml setting for choosing hadoop distro to install
- PNDA-2389: PNDA automatically reboots instances that need rebooting following kernel updates

### Changed
- PNDA-2965: Rename `cloudera_*` role grains to `hadoop_*`

## [1.3.0] 2017-08-01
### Added
- PNDA-2375: Isolate PNDA from breaking dependency change
- PNDA-2676: Support for redhat 7 in the bootstrap scripts. To use redhat set `OS_USER` to `ec2_user` and `imageId` to a redhat 7 AMI in pnda_env.yaml
- PNDA-2680: adding extra index url in pip configuration
- PNDA-2691: Add GPG key for nodejs repo
- PNDA-2706: Refactor template generation
- PNDA-2708: enable offline installation for python
- PNDA-2709: Use PNDA_MIRROR for RPMS, DEBS and misc files
- PNDA-2776: Wait on connectivity to cloud instances before trying to use them
- PNDA-2842: Add key based access to platform-salt git
- PNDA-2851: Add script to wait for ec2 grains
- PNDA-3147: Add dry-run option to CLI that can be used to dry-run the changes to the Cloud Formation stack for create and expand operations.
- Add online fallback for yum

### Changed
- PNDA-2446: Place PNDA packages in root of PNDA_MIRROR
- PNDA-2717: Rename mirror paths
- PNDA-2802: Refactor saltmaster bootstrap code
- PNDA-2809: Update m3 instance type defaults to use the latest m4 family instead
- PNDA-2849: Limit how long we wait for host connectivity
- Remove minion install from salt-master script
- Include time and log level in console output
- Update git version in order to be align with deb mirror script
- Prioritize local mirror over original repo

### Fixed
- PNDA-2758: Fix bootstrap for expand
- PNDA-2803: Remove duplicate salt-master restart commands
- PNDA-2851: Check for ec2 grains before running salt commands as sometimes the ec2 grain wasn't available when running highstate, but was when checked later on
- Fix pylint violations
- Fix issue on easy install configuration

## [1.2.0] 2017-01-20
### Fixed
- PNDA-2595: xvdc volume mounted on /var/log/pnda instead of /var/log/panda

### Added
- PNDA-2043: The CLI now checks for salt error and halt execution if found
- PNDA-2533: Ability to create an ElasticSearch cluster for external usage
- PNDA-2571: Work to allow, future, Offline installation

## [1.1.0] 2016-12-12
### Changed
 - PNDA-2397: Generate the list of valid flavors dynamically. The valid values for the --branch parameter were hard coded, now they are generated based on the folder names under 'cloud-formation/'
 - PNDA-2393: Update OS volume sizes for instances. Increase the standard size from 30 GB to 50 GB and for kafka from 50 GB to 150 GB.
 
### Added
- PNDA-2142: Allow subnet IP ranges to be specified in pnda_env.yaml and used as parameters to the cloud formation templates
- PNDA-2142: Allow any parameters to be passed through to the cloud formation templates, two settings have changed their names because they are now directly passed through - AWS_IMAGE_ID > imageId and AWS_ACCESS_WHITELIST > whitelistSshAccess. Update these in pnda_env.yaml otherwise the default value in the cloud formation template will be used.

### Fixed
 - PNDA-2313: CLI fails fast if errors occur in individual commands. Capturing logs on the cloud instance with `command | tee` (PNDA-2266) caused the CLI to carry on if an error was returned by command, because the final exit code was set by tee.
 - PNDA-2284: Use correct archive parameters to configure s3 archive credentials (the set of variables for the application package bucket were being used)
 - PNDA-2420: Add missing tee to capture logs when running expand salt commands. This missing command also caused the expand operation to fail for standard flavor clusters.


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
