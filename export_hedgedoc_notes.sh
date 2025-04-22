#!/usr/bin/env bash

set -o pipefail

echo "HedgeDoc note exporter"
echo "======================"
echo ""

PRESET_HD_INSTANCE="https://notes.glepage.com"
HD_INSTANCE=""
HD_COOKIE_FILE=$(mktemp)

verify_commands() {
    if ! command -v grep >/dev/null || ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
        echo "grep, cURL and unzip are required to be present."
        exit 1
    fi
}

ask_instance() {
    read -p "Enter your instance root URL (example https://demo.hedgedoc.org): "
    read_ret=$?
    if [ $read_ret -ne 0 ] || [ "$REPLY" == "" ]; then
        echo "Something didn't work. Try again."
        ask_instance
    else
        verify_instance "$REPLY"
        verify_ret=$?
        if [ $verify_ret -ne 0 ]; then
            echo "No HedgeDoc instance detected. Try again."
            ask_instance
        fi
    fi
}

verify_instance() {
    curl -sSLI "$1/status" | grep -q [hH]edgedoc-[vV]ersion
    curl_ret=$?
    HD_INSTANCE="$1"
    return $curl_ret
}

ask_login() {
    read -p "Enter your username/email: "
    if [ $read_ret -ne 0 ] || [ "$REPLY" == "" ]; then
        ask_login
    fi
    login_user="$REPLY"
    read -p "Enter your password: " -s
    if [ $read_ret -ne 0 ]; then
        ask_login
    fi
    login_pass="$REPLY"
    verify_login "$login_user" "$login_pass"
    verify_ret=$?
    if [ $verify_ret -ne 0 ]; then
        echo "Login failed. Try again."
        ask_login
    fi
}

verify_login() {
    curl -X POST -sS --data-urlencode "email=$1" --data-urlencode "password=$2" -o /dev/null -c "$HD_COOKIE_FILE" "$HD_INSTANCE/login"
    return $?
}

export_unzip_userdata() {
    err_count=$1
    zipfile=$(mktemp)
    curl -sS -b "$HD_COOKIE_FILE" -o "$zipfile" "$HD_INSTANCE/me/export"
    curl_ret=$?
    if [ $curl_ret -ne 0 ]; then
        if [ $err_count -gt 5 ]; then
            echo "Failed 5 times to export your user data."
            exit 1
        fi
        export_unzip_userdata $((err_count + 1))
    fi
    out_dir="notes_export"
    unzip -q "$zipfile" -d "$out_dir"
    rm "$zipfile"
    echo "Exported notes to '$out_dir'."
}

clean_up() {
    rm "$HD_COOKIE_FILE"
    unset HD_INSTANCE
    unset HD_COOKIE_FILE
    exit 0
}

verify_commands
# ask_instance
verify_instance $PRESET_HD_INSTANCE
ask_login
export_unzip_userdata 0
clean_up
