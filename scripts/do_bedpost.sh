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
    set dwi_dir=${data_dir}/${subj}/dwi
    cd $dwi_dir

    bedpostx $dwi_dir --model=1
    @ i = $i + 1
end