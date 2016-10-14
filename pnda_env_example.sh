export OS_USER=ubuntu
# URI of platform salt git repository
# PLATFORM_SALT_LOCAL should be removed from client_env.sh if PLATFORM_GIT_REPO_URI is used
export PLATFORM_GIT_REPO_URI=https://github.com/pndaproject/platform-salt.git
export PLATFORM_GIT_BRANCH=master
export PNDA_APPS_CONTAINER=pnda-apps
export PNDA_APPS_FOLDER=releases
export PNDA_ARCHIVE_CONTAINER=pnda-archive
export PACKAGES_SERVER_IP=x.x.x.x
#export CLOUDERA_MIRROR=http://$PACKAGES_SERVER_IP/cloudera_repo
#export ANACONDA_MIRROR=http://$PACKAGES_SERVER_IP/anaconda_repo
export JAVA_MIRROR=http://$PACKAGES_SERVER_IP/components/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz
export PACKAGES_SERVER_URI=http://$PACKAGES_SERVER_IP/packages
export PR_FS_TYPE=s3
#export PR_FS_LOCATION_PATH=/opt/pnda/packages
#export PR_SSHFS_USER=ubuntu
#export PR_SSHFS_HOST=127.0.0.1
#export PR_SSHFS_PATH=/mnt/packages
#export PR_SSHFS_KEY=key.pem
