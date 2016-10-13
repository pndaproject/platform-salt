# Local platform salt to use instead of PLATFORM_GIT_REPO_URI in pnda_env.sh
# PLATFORM_GIT_REPO_URI should be removed from pnda_env.sh if PLATFORM_GIT_LOCAL is used
# export PLATFORM_GIT_LOCAL=/path/to/platform-salt
# API key for full API access for use creating PNDA
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
# API key for s3 access only for PNDA to use at runtime
export S3_ACCESS_KEY_ID=xxxx
export S3_SECRET_ACCESS_KEY=xxxx
export AWS_REGION=eu-west-1
# Standard 64-bit Ubuntu 14.04
export AWS_IMAGE_ID=ami-f95ef58a
export OS_USER=ubuntu
export AWS_ACCESS_WHITELIST=0.0.0.0/0