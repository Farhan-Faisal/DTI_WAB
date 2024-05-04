#!/bin/tcsh

# WRITE CONSTANT PATHS
set ants_folder = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract/ants_warps_converted
set source_dir = /rri_disks/artemis/meltzer_lab/tvb_stroke
set work_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract/participants

mkdir ${work_dir}

set v = `cat pid.txt`
@ i = 1

while ( $i <= $#v )
    set pid = $v[$i]
    set antsDir = ${ants_folder}/${pid}

    mkdir ${work_dir}/${pid}
    cp -r ${source_dir}/${pid}/dwi.bedpostX ${work_dir}/${pid}

    ## ANTS AUTOMATICALLY ADDS
    cp ${antsDir}/diff2struct.nii.gz ${work_dir}/${pid}/dwi.bedpostX/xfms/
    cp ${antsDir}/struct2standard ${work_dir}/${pid}/dwi.bedpostX/xfms/
    cp ${antsDir}/diff2standard.nii.gz ${work_dir}/${pid}/dwi.bedpostX/xfms/
    cp ${antsDir}/standard2diff.nii.gz ${work_dir}/${pid}/dwi.bedpostX/xfms/

    echo ${pid}
    
    @ i = $i + 1
end