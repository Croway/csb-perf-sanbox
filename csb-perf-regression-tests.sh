#!/bin/bash

# @TODO:
# Add transformation logic to the perf regression sample app
# Upgrade to hyperfoil-maven-plugin 0.18 to fix req/s and deps issue when released January 2022 ?
# Implement detection of regression (5% variation seems reasonable)
# Improve the staging support, today we need to hard code it pom.xml files
# Use an archetype instead of copying the perf regression sample app ?

# @NOTES:
# We should be able to build with camel-quarkus version >= 1.1.0 with current build approach
# We don't build using the quarkus-maven-plugin so that we can test against a SNAPSHOT or release candidate versions (don't need to wait for quarkus-platform release)

display_usage() {
  echo "This tool applies a performance test against a list of camel-spring-boot versions. As such, it should be able to detect performance regressions."
  echo -e "Example: $0 3.14.0 3.13.0"
}

if [  $# -le 0 ]
then
  display_usage
  exit 1
fi

mkdir -p csb-versions-under-test
rm -fr csb-versions-under-test/*

pushd . >/dev/null

echo "Version	JVM(req/s)"
for csbVersion in "$@"
do
    # Generate Camel Spring Boot performance regression sample for version ${csbVersion}
    cp -fr csb-perf-regression-sample-base "csb-versions-under-test/csb-perf-regression-sample-${csbVersion}" > /dev/null

    # Replace the pom parent version
	xmllint --shell "csb-versions-under-test/csb-perf-regression-sample-${csbVersion}/pom.xml" >/dev/null <<EOF
setns m=http://maven.apache.org/POM/4.0.0
cd //m:project/m:properties/m:camel-spring-boot-bom.version
set ${csbVersion}
save
EOF

    # Build and run test in JVM mode, then native mode
    pushd "csb-versions-under-test/csb-perf-regression-sample-${csbVersion}" > /dev/null
    mkdir -p target > /dev/null
    mvn integration-test -Pperf-test > target/jvm-logs.txt

	# Print the report line for this version
    NB_REQS=$(grep -Po "RunMojo] Requests/sec: ([0-9.,]+)" "target/jvm-logs.txt" | sed -r 's/RunMojo] Requests\/sec: ([0-9.,]+)/\1/g')
    echo "${csbVersion}	${NB_REQS}"

    popd >/dev/null
done
