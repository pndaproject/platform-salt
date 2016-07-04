# Original code taken from https://github.com/saltstack-formulas/sun-java-formula/
# Slightly modified for PNDA

export JAVA_HOME={{ java_home }}
export PATH=$JAVA_HOME/bin:$PATH
