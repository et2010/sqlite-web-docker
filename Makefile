ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: start
start:
	sqlite_web -p ${SW_PORT} -x -r -P ${SW_PASSWORD} ${SQLITE_DATABASE}