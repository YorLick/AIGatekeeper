# Findre2.cmake — Find re2 (Google RE2) library
#
# Tries CONFIG mode first (Arch/CachyOS provides re2Config.cmake),
# falls back to pkg-config, then manual search (Ubuntu's libre2-dev).
#
# Sets:
#   re2_FOUND         — TRUE if found
#   re2::re2          — imported target (when using find_package)
#   RE2_LIBRARIES     — the library path
#   RE2_INCLUDE_DIRS  — the include directory
#
# Usage: find_package(re2 REQUIRED)

# --- First try CMake config mode (Arch/CachyOS ships re2Config.cmake) ---
# NO_MODULE forces CMake to skip this Find module and go straight to CONFIG
find_package(re2 CONFIG QUIET NO_MODULE)

# --- Fallback: pkg-config (Ubuntu) ---
if(NOT re2_FOUND)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(PC_re2 QUIET re2)
        if(PC_re2_FOUND)
            add_library(re2::re2 UNKNOWN IMPORTED)
            set_target_properties(re2::re2 PROPERTIES
                IMPORTED_LOCATION "${PC_re2_LIBRARIES}"
                INTERFACE_INCLUDE_DIRECTORIES "${PC_re2_INCLUDE_DIRS}"
                INTERFACE_COMPILE_OPTIONS "${PC_re2_CFLAGS_OTHER}"
            )
            set(RE2_LIBRARIES "${PC_re2_LIBRARIES}")
            set(RE2_INCLUDE_DIRS "${PC_re2_INCLUDE_DIRS}")
            set(re2_FOUND TRUE)
        endif()
    endif()
endif()

# --- Final fallback: manual search ---
if(NOT re2_FOUND)
    find_library(RE2_LIBRARIES
        NAMES re2 libre2
        PATHS /usr/lib /usr/lib64 /usr/local/lib /usr/lib/x86_64-linux-gnu
    )
    find_path(RE2_INCLUDE_DIRS
        NAMES re2/re2.h
        PATHS /usr/include /usr/local/include
    )

    if(RE2_LIBRARIES AND RE2_INCLUDE_DIRS)
        add_library(re2::re2 UNKNOWN IMPORTED)
        set_target_properties(re2::re2 PROPERTIES
            IMPORTED_LOCATION "${RE2_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${RE2_INCLUDE_DIRS}"
        )
        set(re2_FOUND TRUE)
        message(STATUS "Found re2 (manual): ${RE2_LIBRARIES}")
    endif()
endif()

# --- Final check ---
if(re2_FOUND)
    message(STATUS "Found re2: ${RE2_LIBRARIES}")
elseif(re2_FIND_REQUIRED)
    message(FATAL_ERROR "Could NOT find re2 library. "
        "Install: apt install libre2-dev (Debian/Ubuntu) / "
        "yum install re2-devel (Fedora) / "
        "pacman -S re2 (Arch/CachyOS)")
endif()
