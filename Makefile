################################################################################
format:
	format-c-cpp format-cmake format-dockerfile

format-c-cpp:
	clang-format -i /workspace/**/*.cpp /workspace/**/*.h

format-cmake:
	cmake-format -i --tab-size 4 --line-width 120 --dangle-parens true /workspace/**/CMakeLists.txt

format-dockerfile:
	docfmt fmt --write /workspace/**/*ockerfile*

################################################################################
format-check:
	format-check-c-cpp

format-check-c-cpp:
	clang-format --dry-run -Werror /workspace/**/*.cpp /workspace/**/*.h

format-check-dockerfile:
	docfmt fmt --list /workspace/**/*ockerfile*

################################################################################
lint:
	lint-c-cpp lint-cmake lint-dockerfile

lint-c-cpp:
	clang-tidy /workspace/**/*.cpp /workspace/**/*.h --fix-errors

lint-cmake:
	cmakelint /workspace/**/CMakeLists.txt

lint-dockerfile:
	dockerfilelint /workspace/**/*ockerfile*