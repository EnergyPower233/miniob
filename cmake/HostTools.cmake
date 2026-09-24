# Homebrew supports Intel and Apple Silicon installations. Respect explicit
# FLEX_EXECUTABLE/BISON_EXECUTABLE settings and discover keg-only tools otherwise.
if(APPLE)
  find_program(MINIOB_BREW NAMES brew)
  if(MINIOB_BREW)
    foreach(_tool IN ITEMS flex bison)
      string(TOUPPER "${_tool}" _upper)
      if(NOT ${_upper}_EXECUTABLE)
        execute_process(COMMAND "${MINIOB_BREW}" --prefix "${_tool}"
          RESULT_VARIABLE _result OUTPUT_VARIABLE _prefix
          OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
        if(_result EQUAL 0 AND EXISTS "${_prefix}/bin/${_tool}")
          set(${_upper}_EXECUTABLE "${_prefix}/bin/${_tool}" CACHE FILEPATH "${_tool} executable")
        endif()
      endif()
    endforeach()
  endif()
endif()
