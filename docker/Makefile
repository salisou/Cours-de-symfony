APP_ENV = dev

build:
	./dc.sh build

start:
	./dc.sh up -d

stop:
	./dc.sh down

log:
	./dc.sh log

rebuild:
	./dc.sh down
	./dc.sh build
	./dc.sh up -d
	./dc.sh log
purge:
	./dc.sh purge

enter:
	./dc.sh enter

messenger-send:
	./dc.sh messenger-send

messenger-consume:
	./dc.sh messenger-consume

test:
	./dc.sh test

test-text:
	./dc.sh test-text

test-coverage:
	./dc.sh test-coverage