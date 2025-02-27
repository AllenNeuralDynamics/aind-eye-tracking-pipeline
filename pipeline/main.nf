#!/usr/bin/env nextflow
// hash:sha256:0bceb9e4fd769fdabe642d332382add2da2b369c02f61f3b2593d0c99385bd52

nextflow.enable.dsl = 1

params.multiplane_ophys_770962_2025_02_25_12_14_00_url = 's3://aind-open-data/multiplane-ophys_770962_2025-02-25_12-14-00'

multiplane_ophys_770962_2025_02_25_12_14_00_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.multiplane_ophys_770962_2025_02_25_12_14_00_url + "/", type: 'any')
capsule_nwb_packaging_subject_capsule_1_to_capsule_nwb_packaging_eye_tracking_2_2 = channel.create()
multiplane_ophys_770962_2025_02_25_12_14_00_to_nwb_packaging_eye_tracking_3 = channel.fromPath(params.multiplane_ophys_770962_2025_02_25_12_14_00_url + "/", type: 'any')
capsule_aind_capsule_eye_tracking_3_to_capsule_nwb_packaging_eye_tracking_2_4 = channel.create()
multiplane_ophys_770962_2025_02_25_12_14_00_to_aind_capsule_eye_tracking_5 = channel.fromPath(params.multiplane_ophys_770962_2025_02_25_12_14_00_url + "/", type: 'any')

// capsule - NWB-Packaging-Subject-Capsule
process capsule_nwb_packaging_subject_capsule_1 {
	tag 'capsule-8198603'
	container "$REGISTRY_HOST/published/bdc9f09f-0005-4d09-aaf9-7e82abd93f19:v2"

	cpus 1
	memory '8 GB'

	input:
	path 'capsule/data/ophys_session' from multiplane_ophys_770962_2025_02_25_12_14_00_to_nwb_packaging_subject_capsule_1.collect()

	output:
	path 'capsule/results/*' into capsule_nwb_packaging_subject_capsule_1_to_capsule_nwb_packaging_eye_tracking_2_2

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=bdc9f09f-0005-4d09-aaf9-7e82abd93f19
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v2.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8198603.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_nwb_packaging_subject_capsule_1_args}

	echo "[${task.tag}] completed!"
	"""
}

// capsule - NWB-Packaging-Eye-Tracking
process capsule_nwb_packaging_eye_tracking_2 {
	tag 'capsule-8870958'
	container "$REGISTRY_HOST/published/8593a5d3-f123-4334-814d-c95bac173591:v1"

	cpus 1
	memory '8 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/nwb/' from capsule_nwb_packaging_subject_capsule_1_to_capsule_nwb_packaging_eye_tracking_2_2.collect()
	path 'capsule/data/multiplane-ophys_' from multiplane_ophys_770962_2025_02_25_12_14_00_to_nwb_packaging_eye_tracking_3.collect()
	path 'capsule/data/eye_tracking/' from capsule_aind_capsule_eye_tracking_3_to_capsule_nwb_packaging_eye_tracking_2_4.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=8593a5d3-f123-4334-814d-c95bac173591
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-8870958.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

// capsule - aind-capsule-eye-tracking
process capsule_aind_capsule_eye_tracking_3 {
	tag 'capsule-1651093'
	container "$REGISTRY_HOST/capsule/4cf0be83-2245-4bb1-a55c-a78201b14bfe"

	cpus 16
	memory '61 GB'
	accelerator 1
	label 'gpu'

	input:
	path 'capsule/data' from multiplane_ophys_770962_2025_02_25_12_14_00_to_aind_capsule_eye_tracking_5.collect()

	output:
	path 'capsule/results/*' into capsule_aind_capsule_eye_tracking_3_to_capsule_nwb_packaging_eye_tracking_2_4

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=4cf0be83-2245-4bb1-a55c-a78201b14bfe
	export CO_CPUS=16
	export CO_MEMORY=65498251264

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	ln -s "/tmp/data/universal_eye_tracking-peterl-2019-07-10" "capsule/data/universal_eye_tracking-peterl-2019-07-10" # id: 05529cfc-23fe-4ead-9490-71763e9f7c01

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-1651093.git" capsule-repo
	git -C capsule-repo checkout d7ac3d3bbc600f7ba47d62ee856f328e49795ca5 --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}
