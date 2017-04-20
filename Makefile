PRJTAG := erlang-mqtt

GIT_DESC := $(shell git describe --tags --always --dirty --match "v[0-9]*")

VERSION_TAG := $(patsubst v%,%,$(GIT_DESC))

.PHONY: all
all: test

.PHONY: test
test:
	@-docker pull eclipse-mosquitto:1.4.10 >/dev/null
	@-docker rm "$(PRJTAG)-$(VERSION_TAG)" -f  2>/dev/null || true
	@-docker run -d --name "$(PRJTAG)-$(VERSION_TAG)" -it --rm -p 1883:1883 eclipse-mosquitto >/dev/null
	@while ! echo exit | docker ps -l | grep -e "eclipse-mosquitto" | grep "Up " | grep -q "1883->1883/tcp"; do sleep 2; done
	mix test --include external:true
	@-docker rm "$(PRJTAG)-$(VERSION_TAG)" -f >/dev/null
