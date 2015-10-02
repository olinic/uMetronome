include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    UMetronomebackend_SRCS
    modules/UMetronome/backend.cpp
    modules/UMetronome/mytype.cpp
    modules/UMetronome/uTimer.cpp
)

# Make the unit test files visible on qtcreator
add_custom_target(UMetronomebackend_UNITTEST_QML_FILES ALL SOURCES "tests/unit/tst_mytype.qml")

add_library(UMetronomebackend MODULE
    ${UMetronomebackend_SRCS}
)

set_target_properties(UMetronomebackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY UMetronome)

qt5_use_modules(UMetronomebackend Gui Qml Quick)

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(UMetronomebackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/UMetronome/qmldir ${CMAKE_CURRENT_BINARY_DIR}/UMetronome
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS UMetronomebackend DESTINATION ${QT_IMPORTS_DIR}/UMetronome/)
install(FILES   modules/UMetronome/qmldir DESTINATION ${QT_IMPORTS_DIR}/UMetronome/)

