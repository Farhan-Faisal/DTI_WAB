#!/bin/tcsh

# SET UP ENV PATHS
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

# SET UP DATA PATHS
set data_dir = /rri_disks/artemis/meltzer_lab/tvb_stroke
set subj_file = ${data_dir}/scripts/all_subjs.txt

set v = `cat ${subj_file}`
@ i = 1

# PREP DTI
while ( $i <= $#v )
    set subj = $v[$i]

    cd $data_dir/${subj}/dwi/

    #strip skull, make brain mask in diff space
    echo "computing brain mask for subj " $subj
    fslroi ${subj}_dwi.nii.gz nodif 0 1
    bet nodif nodif_brain -f .3 -m

    #eddy current correction
    echo "eddy current correction for subj " $subj
    eddy_correct ${subj}_dwi.nii.gz data.nii.gz 0

    #fit diffusion tensors
    echo "fitting tensors for subj " $subj
    ${fsl_dir}/dtifit --data=data.nii.gz --out=dti --mask=nodif_brain_mask.nii.gz --bvecs=bvecs --bvals=bvals

    @ i = $i + 1
end