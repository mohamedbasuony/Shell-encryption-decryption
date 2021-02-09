#!/bin/bash
source backup_restore_lib.sh

validate_restore_param $@
restore $@
