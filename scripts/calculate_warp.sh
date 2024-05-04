#!/bin/tcsh

# STEP 1: SET UP ENV PATHS
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

setenv ANTSPATH /software/ants-2.1.0
setenv PATH ${ANTSPATH}:${PATH}
source ${ANTSPATH}

# STEP 2: SET UP CONSTANT PATHS
set MNI_standard = /software/fsl/data/standard/MNI152_T1_2mm.nii.gz
set work_dir = /rri_disks/artemis/meltzer_lab/tvb_stroke
set curr_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract

mkdir ${curr_dir}/ants_warps

# READ PID FROM FILE
set v = `cat pid.txt`
@ i = 1

while ( $i <= $#v )
    # STEP 3: SET UP DIRECTORY PATHS
    set pid = $v[$i]
    set bedpost_dir = ${work_dir}/${pid}/dwi.bedpostX
    set antsDir = ${curr_dir}/ants_warps/${pid}

    set EPI_image = ${bedpost_dir}/nodif_brain.nii.gz
    set MPRAGE_T1 = ${work_dir}/${pid}/anat/${pid}_mprage.nii.gz
    set t1_brain = ${antsDir}/${pid}_t1_brain.nii.gz

    ## ANTS AUTOMATICALLY ADDS .nii.gz
    set diff2struct = ${antsDir}/diff2struct.nii.gz
    set struct2standard = ${antsDir}/struct2standard
    set diff2standard =  ${antsDir}/diff2standard.nii.gz
    set standard2diff =  ${antsDir}/standard2diff.nii.gz

    # STEP 4:
    mkdir ${curr_dir}/ants_warps/${pid}

    # Extract brain mask
    bet ${MPRAGE_T1} ${t1_brain}

    # CALCULATE LINEAR DIFF_2_STRUCT WARP
    epi_reg --epi=${EPI_image} --t1=${MPRAGE_T1} --t1brain=${t1_brain} --out=${diff2struct}

    # CALCULATE ANTS STRUCT_2_STANDARD WARP 
    /software/ants-2.1.0/antsRegistrationSyN.sh -d 3 -f ${MNI_standard} -m ${MPRAGE_T1} -o ${struct2standard}

    @ i = $i + 1
end