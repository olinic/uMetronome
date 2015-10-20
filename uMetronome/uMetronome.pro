TEMPLATE = aux
TARGET = uMetronome

RESOURCES += uMetronome.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

SOUND_FILES +=  sounds \
                $$files(sounds/*.wav, true)

ICON_FILES +=   icons \
                $$files(icons/*.svg, true)

CONF_FILES +=  uMetronome.apparmor \
               uMetronome.desktop \
               uMetronome.svg

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES}

#specify where the qml/js files are installed to
qml_files.path = /uMetronome
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /uMetronome
config_files.files += $${CONF_FILES}

sound_files.path = /uMetronome/sounds
sound_files.files += $${SOUND_FILES}

icon_files.path = /uMetronome/icons
icon_files.files += $${ICON_FILES}

INSTALLS+=config_files qml_files sound_files icon_files

