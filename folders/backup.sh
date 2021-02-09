#!/bin/bash
source backup_restore_lib.sh

validate_backup_param $@
backup $@

