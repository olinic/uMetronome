file(GLOB QML_JS_FILES *.qml *.js)
file(GLOB_RECURSE SOUND_FILES sounds/*.wav)
file(GLOB_RECURSE ICON_FILES icons/*.svg)

# Make the files visible on qtcreator
add_custom_target(umetronome_QMlFiles ALL SOURCES ${QML_JS_FILES})

# Substitute variables in the desktop file
configure_file(${DESKTOP_FILE_NAME}.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME}.in)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME} DESTINATION ${DESKTOP_DIR})
install(FILES ${QML_JS_FILES} DESTINATION ${UMETRONOME_DIR})
install(FILES ${SOUND_FILES} DESTINATION ${UMETRONOME_DIR}/sounds)
install(FILES ${ICON_FILES} DESTINATION ${UMETRONOME_DIR}/icons)

# Make the autpilot files visible in qtcreator
file(GLOB_RECURSE AUTOPILOT_TEST_FILES *.py)
add_custom_target(umetronome_AutopilotFiles ALL SOURCES ${AUTOPILOT_TEST_FILES})

# Make the unit test files visible in qtcreator
file(GLOB_RECURSE UNIT_TEST_FILES tests/unit/*.qml)
add_custom_target(umetronome_UnitTestFiles ALL SOURCES ${UNIT_TEST_FILES})

# Make sound files visible in qtcreator
add_custom_target(umetronome_SoundFiles ALL SOURCES ${SOUND_FILES})

# Make icons visible in qtcreator
add_custom_target(umetronome_IconFiles ALL SOURCES ${ICON_FILES})
