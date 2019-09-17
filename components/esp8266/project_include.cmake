set(BOOTLOADER_FIRMWARE_DIR ${CMAKE_CURRENT_LIST_DIR}/firmware)

#configurate downloading parameters
set(ESPTOOLPY_FLASHSIZE ${CONFIG_ESPTOOLPY_FLASHSIZE})
set(ESPTOOLPY_FLASHMODE ${CONFIG_ESPTOOLPY_FLASHMODE})
set(ESPTOOLPY_FLASHFREQ ${CONFIG_ESPTOOLPY_FLASHFREQ})

if(${ESPTOOLPY_FLASHSIZE} STREQUAL "512KB")
set(BLANK_BIN_OFFSET1 0x7B000)
set(BLANK_BIN_OFFSET2 0x7E000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x7C000)
set(ESP8266_SIZEMAP 0)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "1MB")
set(BLANK_BIN_OFFSET1 0xFB000)
set(BLANK_BIN_OFFSET2 0xFE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0xFC000)
set(ESP8266_SIZEMAP 2)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "2MB")
set(BLANK_BIN_OFFSET1 0x1FB000)
set(BLANK_BIN_OFFSET2 0x1FE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x1FC000)
set(ESP8266_SIZEMAP 3)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "2MB-c1")
set(BLANK_BIN_OFFSET1 0x1FB000)
set(BLANK_BIN_OFFSET2 0x1FE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x1FC000)
set(ESP8266_SIZEMAP 5)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "4MB")
set(BLANK_BIN_OFFSET1 0x3FB000)
set(BLANK_BIN_OFFSET2 0x3FE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x3FC000)
set(ESP8266_SIZEMAP 4)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "4MB-c1")
set(BLANK_BIN_OFFSET1 0x3FB000)
set(BLANK_BIN_OFFSET2 0x3FE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x3FC000)
set(ESP8266_SIZEMAP 6)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "8MB")
set(BLANK_BIN_OFFSET1 0x7FB000)
set(BLANK_BIN_OFFSET2 0x7FE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0x7FC000)
set(ESP8266_SIZEMAP 8)
endif()
if(${ESPTOOLPY_FLASHSIZE} STREQUAL "16MB")
set(BLANK_BIN_OFFSET1 0xFFB000)
set(BLANK_BIN_OFFSET2 0xFFE000)
set(ESP_INIT_DATA_DEFAULT_BIN_OFFSET 0xFFC000)
set(ESP8266_SIZEMAP 9)
endif()

set(BOOTLOADER_BIN_OFFSET 0)
set(APP_OFFSET 0x1000)

set(ESP8266_BOOTMODE 2) # always be 2

if(${ESPTOOLPY_FLASHMODE} STREQUAL "qio")
set(ESP8266_FLASHMODE 0)
endif()
if(${ESPTOOLPY_FLASHMODE} STREQUAL "qout")
set(ESP8266_FLASHMODE 1)
endif()
if(${ESPTOOLPY_FLASHMODE} STREQUAL "dio")
set(ESP8266_FLASHMODE 2)
endif()
if(${ESPTOOLPY_FLASHMODE} STREQUAL "dout")
set(ESP8266_FLASHMODE 3)
endif()

if(${ESPTOOLPY_FLASHFREQ} STREQUAL "20m")
set(ESP8266_FREQDIV 2)
endif()
if(${ESPTOOLPY_FLASHFREQ} STREQUAL "26m")
set(ESP8266_FREQDIV 1)
endif()
if(${ESPTOOLPY_FLASHFREQ} STREQUAL "40m")
set(ESP8266_FREQDIV 0)
endif()
if(${ESPTOOLPY_FLASHFREQ} STREQUAL "80m")
set(ESP8266_FREQDIV 15)
endif()

set(ESP8266_BINSCRIPT ${PYTHON} $(IDF_PATH)/tools/gen_appbin.py)

#
# Add 'app.bin' target - generates with elf2image
#
add_custom_command(OUTPUT ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJCOPY_COMPILER} --only-section .text -O binary ${PROJECT_NAME}.elf eagle.app.v6.text.bin
    COMMAND ${CMAKE_OBJCOPY_COMPILER} --only-section .data -O binary ${PROJECT_NAME}.elf eagle.app.v6.data.bin
    COMMAND ${CMAKE_OBJCOPY_COMPILER} --only-section .rodata -O binary ${PROJECT_NAME}.elf eagle.app.v6.rodata.bin
	COMMAND ${CMAKE_OBJCOPY_COMPILER} --only-section .irom0.text -O binary ${PROJECT_NAME}.elf eagle.app.v6.irom0text.bin
	COMMAND ${ESP8266_BINSCRIPT} ${PROJECT_NAME}.elf ${ESP8266_BOOTMODE} ${ESP8266_FLASHMODE} ${ESP8266_FREQDIV} ${ESP8266_SIZEMAP}
	COMMAND mv eagle.app.flash.bin ${PROJECT_NAME}.bin
	COMMAND rm eagle.app.v6.text.bin eagle.app.v6.data.bin eagle.app.v6.rodata.bin eagle.app.v6.irom0text.bin
    DEPENDS ${PROJECT_NAME}.elf
    VERBATIM
    )
add_custom_target(app ALL DEPENDS ${PROJECT_NAME}.bin)

set(BLANK_BIN ${BOOTLOADER_FIRMWARE_DIR}/blank.bin)
set(ESP_INIT_DATA_DEFAULT_BIN ${BOOTLOADER_FIRMWARE_DIR}/esp_init_data_default.bin)
set(BOOTLOADER_BIN ${BOOTLOADER_FIRMWARE_DIR}/boot_v1.7.bin)

set(PYTHON ${CONFIG_PYTHON})
set(ESPTOOLPY_SRC $(IDF_PATH)/components/esptool_py/esptool/esptool.py)

set(CHIP esp8266)
set(ESPPORT ${CONFIG_ESPTOOLPY_PORT})
set(ESPBAUD ${CONFIG_ESPTOOLPY_BAUD})
set(ESPFLASHMODE ${CONFIG_ESPTOOLPY_FLASHMODE})
set(ESPFLASHFREQ ${CONFIG_ESPTOOLPY_FLASHFREQ})
set(ESPFLASHSIZE ${CONFIG_ESPTOOLPY_FLASHSIZE})
set(ESPTOOLPY ${PYTHON} ${ESPTOOLPY_SRC} --chip ${CHIP})

set(ESPTOOL_WRITE_FLASH_OPTIONS --flash_mode ${ESPFLASHMODE} --flash_freq ${ESPFLASHFREQ} --flash_size ${ESPFLASHSIZE})

set(ESPTOOLPY_SERIAL ${ESPTOOLPY} --port ${ESPPORT} --baud ${ESPBAUD} --before ${CONFIG_ESPTOOLPY_BEFORE} --after ${CONFIG_ESPTOOLPY_AFTER})

set(ESPTOOLPY_WRITE_FLASH ${ESPTOOLPY_SERIAL} write_flash -z ${ESPTOOL_WRITE_FLASH_OPTIONS})

set(APP_BIN ${PROJECT_NAME}.bin)

set(ESPTOOL_ALL_FLASH_ARGS ${BOOTLOADER_BIN_OFFSET} ${BOOTLOADER_BIN}
                           ${APP_OFFSET} ${APP_BIN}
                           ${ESP_INIT_DATA_DEFAULT_BIN_OFFSET} ${ESP_INIT_DATA_DEFAULT_BIN}
                           ${BLANK_BIN_OFFSET1} ${BLANK_BIN}
                           ${BLANK_BIN_OFFSET2} ${BLANK_BIN})

add_custom_target(flash DEPENDS ${PROJECT_NAME}.bin
    COMMAND echo "Flashing binaries to serial port ${ESPPORT} app at offset ${APP_OFFSET}..."
    COMMAND echo ${ESPTOOL_ALL_FLASH_ARGS} 
    COMMAND ${ESPTOOLPY_WRITE_FLASH} ${ESPTOOL_ALL_FLASH_ARGS}
    COMMAND echo "success"
    )

add_custom_target(erase_flash DEPENDS ""
    COMMAND echo "Erasing entire flash..."
    COMMAND ${ESPTOOLPY_SERIAL} erase_flash
    COMMAND echo "success"
    )

set(MONITOR_PYTHON ${PYTHON})
set(MONITORBAUD ${CONFIG_MONITOR_BAUD})
set(APP_ELF ${PROJECT_NAME}.elf)
set(MONITOR_OPTS --baud ${MONITORBAUD} --port ${ESPPORT} --toolchain-prefix ${CONFIG_TOOLPREFIX} ${APP_ELF})

function(esp_monitor func dependencies)
    add_custom_target(${func} DEPENDS ${dependencies}
        COMMAND echo "start monitor ... "
        COMMAND echo $(MONITOR_PYTHON) ${IDF_PATH}/tools/idf_monitor.py ${MONITOR_OPTS} 
        COMMAND $(MONITOR_PYTHON) ${IDF_PATH}/tools/idf_monitor.py ${MONITOR_OPTS} 
        COMMAND echo "idf monitor exit"
        )
endfunction()

esp_monitor(monitor "")