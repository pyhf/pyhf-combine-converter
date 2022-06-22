default: image

all: image

image:
	docker pull aperloff/cms-cvmfs-docker:latest
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

image_buildx:
	docker pull aperloff/cms-cvmfs-docker:latest
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
		--file docker/buildx/Dockerfile \
		--build-arg ARG_CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		--build-arg ARG_MY_UID=$(id -u) \
		--build-arg ARG_MY_GID=$(id -g) \
		--tag pyhf/pyhf-combine-converter:debug-buildx \
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
		aperloff/cms-cvmfs-docker:latest

image_dirty:
	docker build . \
		-f docker/dirty/Dockerfile \
		--build-arg BASE_IMAGE=pyhf/pyhf-combine-converter:commit-build \
		--build-arg CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		--tag pyhf/pyhf-combine-converter:latest \
		--tag pyhf/pyhf-combine-converter:cmssw-11.2.0-python3

run_dirty:
	docker run \
		--rm \
		-it \
		-P \
		--device /dev/fuse \
		--cap-add SYS_ADMIN \
		--security-opt apparmor:unconfined \
		-e CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		pyhf/pyhf-combine-converter:latest

run_buildx:
	docker run \
		--rm \
		-it \
		-P \
		--device /dev/fuse \
		--cap-add SYS_ADMIN \
		--security-opt apparmor:unconfined \
		-e CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" \
		pyhf/pyhf-combine-converter:debug-buildx
