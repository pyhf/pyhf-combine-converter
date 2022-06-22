default: image

all: image

image:
	docker pull aperloff/cms-cvmfs-docker:latest
	docker buildx prune -f
	docker buildx create \
		--driver-opt \
		image=moby/buildkit:master \
		--use \
		--name insecure-builder \
		--buildkitd-flags '--allow-insecure-entitlement security.insecure'
	docker buildx use insecure-builder
	docker buildx build \
		--load \
		--allow security.insecure \
		--file docker/Dockerfile \
		--build-arg ARG_CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		--build-arg ARG_MY_UID=$(id -u) \
		--build-arg ARG_MY_GID=$(id -g) \
		--tag pyhf/pyhf-combine-converter:debug-local \
		.
	docker buildx rm insecure-builder

run:
	docker run \
		--rm \
		-it \
		-P \
		--device /dev/fuse \
		--cap-add SYS_ADMIN \
		--security-opt apparmor:unconfined \
		-e CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		pyhf/pyhf-combine-converter:debug-local
