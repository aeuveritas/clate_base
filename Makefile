TAG = 0.1

build:
	docker build -t clate_base:${TAG} .

push:
	docker tag clate_base:${TAG} aeuveritas/clate_base:${TAG}
	docker push aeuveritas/clate_base:${TAG}

all: build push