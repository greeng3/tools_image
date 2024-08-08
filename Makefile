################################################################################
format:
	format-c-cpp

format-c-cpp:
	clang-format -i /workspace/**/*.cpp /workspace/**/*.h

format-cake:
	cmake-format -i --tab-size 4 --line-width 120 --dangle-parens true /workspace/**/CMakeLists.txt

################################################################################
format-check:
	format-check-c-cpp

format-c-cpp:
	clang-format --dry-run -Werror /workspace/**/*.cpp /workspace/**/*.h

################################################################################
lint:
	lint-c-cpp

lint-c-cpp:
	clang-tidy /workspace/**/*.cpp /workspace/**/*.h --fix-errors

lint-cmake:
	cmakelint /workspace/**/CMakeLists.txt