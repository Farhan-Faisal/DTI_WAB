#!/bin/tcsh

# STEP 1: SET UP ENV PATHS
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

setenv ANTSPATH /software/ants-2.1.0
setenv PATH ${ANTSPATH}:${PATH}
source ${ANTSPATH}

# STEP 2: SET UP DIRECTORIES
set atlas_img = /rri_disks/artemis/meltzer_lab/shared/refbrains/MNI_caez_ml_18.nii.gz
set work_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract
set stroke_dir = /rri_disks/artemis/meltzer_lab/tvb_stroke
set warp_dir = ${work_dir}/ants_warps
set out_dir = ${work_dir}/atlas_language_roi

mkdir ${out_dir}

# READ PID FROM FILE
set v = `cat pid.txt`
@ i = 1


while ( $i <= $#v )
    # STEP 3: SET UP DIRECTORY PATHS
    set pid = $v[$i]

    mkdir ${out_dir}/${pid}

    cp ${stroke_dir}/${pid}/anat/lesionmask.nii ${out_dir}/${pid}
    cp ${stroke_dir}/${pid}/anat/${pid}_mprage.nii.gz ${out_dir}/${pid}

    @ i = $i + 1
    echo ${pid}
end 

set v = `cat pid.txt`
@ i = 1
while ( $i <= $#v )
    # STEP 3: SET UP DIRECTORY PATHS
    set pid = $v[$i]

    set T1_IMAGE = ${out_dir}/${pid}/${pid}_mprage.nii.gz
    set standard2struct_warp = ${warp_dir}/${pid}/struct2standard1InverseWarp.nii.gz
    set standard2struct_mat = ${warp_dir}/${pid}/struct2standard0GenericAffine.mat

    WarpImageMultiTransform 3 ${atlas_img} ${out_dir}/${pid}/${pid}_T1_atlas.nii.gz -R ${warp_dir}/${pid}/${pid}_mprage.nii.gz --use-NN -i ${standard2struct_mat} ${standard2struct_warp}
    @ i = $i + 1
    echo ${pid}
end