#!/bin/sh

# Test mode
case "$1" in
    --test)
        GREEN='\033[32m'
        RED='\033[31m'
        RESET='\033[0m'

        echo "Performing container test"

        printf '%b' "(1/2) Firmware download test: "
        OUTPUT=$(./download-ikea-firmware.sh 2>&1 || true)
        case "$OUTPUT" in
            *"Download finished"*)
                printf '%b\n' "${GREEN}PASSED${RESET}"
                ;;
            *)
                printf '%b\n%s\n%b\n' "${RED}FAILED${RESET}" "$OUTPUT" "${RED}ERROR: Firmware download failed${RESET}" >&2
                exit 42
                ;;
        esac

        printf '%b' "(2/2) Crontab validation test: "
        OUTPUT=$(supercronic -test -debug crontab 2>&1 || true)
        case "$OUTPUT" in
            *"crontab is valid"*)
                printf '%b\n' "${GREEN}PASSED${RESET}"
                ;;
            *)
                printf '%b\n%s\n%b\n' "${RED}FAILED${RESET}" "$OUTPUT" "${RED}ERROR: crontab validation failed${RESET}" >&2
                exit 43
                ;;
        esac

        printf '%b\n' "${GREEN}All tests completed successfully${RESET}"
        exit 0
        ;;
esac

# Normal execution
echo "Initial download of IKEA Tradfri firmware"
./download-ikea-firmware.sh

echo "Starting supercronic..."
exec supercronic "$@" crontab
