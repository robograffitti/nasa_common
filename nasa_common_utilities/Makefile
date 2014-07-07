# This Makefile is here for 'rosmake' like systems. In case you don't use
# ROS, it will create a build directory for you and build the package with
# default settings. It will install it at the same location as the RTT is installed.

# Default for EXTRA_CMAKE_FLAGS
$(eval EXTRA_CMAKE_FLAGS := -DCAPTURE_CODE_COVERAGE=OFF)

ifdef ROS_ROOT
include $(shell rospack find mk)/cmake.mk
else
$(warning This Makefile builds this package with default settings)
all:
	mkdir -p build
	cd build ; cmake .. -DINSTALL_PATH=orocos && make
	echo -e "\n Now do 'make install' to install this package.\n"
install: all
	cd build ; make install
endif

enableCoverage:
	$(eval EXTRA_CMAKE_FLAGS := -DCAPTURE_CODE_COVERAGE=ON)

testWithCoverage: enableCoverage test

spotless: clean
	rm -rf lib bin
