#!/usr/bin/env nextflow
// hash:sha256:47931abf87aa15063f2992066c7215664854f3647648d94c07ece05eaad44a8f

nextflow.enable.dsl = 1

params.ophys_mount_url = 's3://aind-open-data/multiplane-ophys_770962_2025-02-25_12-14-00'

ophys_mount_to_nwb_packaging_subject_capsule_1 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
ophys_mount_to_copy_of_nwb_packaging_eye_tracking_2 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')
capsule_nwb_packaging_subject_capsule_1_to_capsule_copy_of_nwb_packaging_eye_tracking_2_3 = channel.create()
capsule_copy_of_aind_capsule_eye_tracking_3_to_capsule_copy_of_nwb_packaging_eye_tracking_2_4 = channel.create()
ophys_mount_to_copy_of_aind_capsule_eye_tracking_5 = channel.fromPath(params.ophys_mount_url + "/", type: 'any')

// capsule - NWB-Packaging-Subject-Capsule
process capsule_nwb_packaging_subject_capsule_1 {
	tag 'capsule-8198603'
	container "$REGISTRY_HOST/published/bdc9f09f-0005-4d09-aaf9-7e82abd93f19:v2"

	cpus 1
	memory '8 GB'

	input:
	path 'capsule/data/ophys_session' from ophys_mount_to_nwb_packaging_subject_capsule_1.collect()

	output:
	path 'capsule/results/*' into capsule_nwb_packaging_subject_capsule_1_to_capsule_copy_of_nwb_packaging_eye_tracking_2_3

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

// capsule - Copy of NWB-Packaging-Eye-Tracking
process capsule_copy_of_nwb_packaging_eye_tracking_2 {
	tag 'capsule-0280622'
	container "$REGISTRY_HOST/capsule/6776e2e4-70fc-4cb9-8894-504c569a1cd3:411a947541e561a790fd72d719dc1c8a"

	cpus 2
	memory '16 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data' from ophys_mount_to_copy_of_nwb_packaging_eye_tracking_2.collect()
	path 'capsule/data/nwb/' from capsule_nwb_packaging_subject_capsule_1_to_capsule_copy_of_nwb_packaging_eye_tracking_2_3.collect()
	path 'capsule/data/eye_tracking/' from capsule_copy_of_aind_capsule_eye_tracking_3_to_capsule_copy_of_nwb_packaging_eye_tracking_2_4.collect()

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=6776e2e4-70fc-4cb9-8894-504c569a1cd3
	export CO_CPUS=2
	export CO_MEMORY=17179869184

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-0280622.git" capsule-repo
	git -C capsule-repo checkout 24b4b86316f7b3c93642ea7c46787fb1eead1462 --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

// capsule - COPY of aind-capsule-eye-tracking
process capsule_copy_of_aind_capsule_eye_tracking_3 {
	tag 'capsule-9626122'
	container "$REGISTRY_HOST/capsule/db1debb8-22f5-4922-8213-5fab751bfcc5:e8b81a2de3e3c4e9381921611bce0331"

	cpus 16
	memory '61 GB'
	accelerator 1
	label 'gpu'

	input:
	path 'capsule/data' from ophys_mount_to_copy_of_aind_capsule_eye_tracking_5.collect()

	output:
	path 'capsule/results/*' into capsule_copy_of_aind_capsule_eye_tracking_3_to_capsule_copy_of_nwb_packaging_eye_tracking_2_4

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=db1debb8-22f5-4922-8213-5fab751bfcc5
	export CO_CPUS=16
	export CO_MEMORY=65498251264

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	ln -s "/tmp/data/universal_eye_tracking-peterl-2019-07-10" "capsule/data/universal_eye_tracking-peterl-2019-07-10" # id: 05529cfc-23fe-4ead-9490-71763e9f7c01

	echo "[${task.tag}] cloning git repo..."
	git clone "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-9626122.git" capsule-repo
	git -C capsule-repo checkout f27fd5550fdfdc55ac752020eb826aa7d9a6697f --quiet
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}
