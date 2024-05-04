#!/bin/tcsh

# STEP 1: SET UP ENV PATHS
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

# STEP 2: SET UP FSL PATHS
set seed_ref = /software/fsl/data/standard/MNI152_T1_2mm.nii.gz
set xtract_data_dir = /software/fsl/etc/xtract_data
set work_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract

# READ PID FROM FILE
mkdir ${work_dir}/native_diffusion_space_output/

set v = `cat pid.txt`
@ i = 1

while ( $i <= $#v )
    # STEP 3: SET UP DIRECTORY PATHS
    set pid = $v[$i]
    set out_dir = ${work_dir}/native_diffusion_space_output/${pid}
    set bedpost_dir = ${work_dir}/participants/${pid}/dwi.bedpostX

    # STEP 4: RUN XTRACT
    mkdir native_diffusion_space_output/${pid}
    xtract -native -bpx ${bedpost_dir} -out ${out_dir} -species HUMAN
    @ i = $i + 1
end