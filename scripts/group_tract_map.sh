#!/bin/tcsh

# STEP 1: SET UP ENV PATHS
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

setenv ANTSPATH /software/ants-2.1.0
setenv PATH ${ANTSPATH}:${PATH}
source ${ANTSPATH}

# STEP 2: SET UP DIRECTORIES
set work_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract
set warp_dir = ${work_dir}/ants_warps_converted
set out_dir = ${work_dir}/native_diffusion_space_output
set MNI_standard = ${work_dir}/ants_warps/MNI152_T1_2mm.nii.gz


# READ PID FROM FILE
set v = `cat pid.txt`
@ i = 1

## GET THE DESIRED TRACTS IN MNI SPACE FOR EACH PARTICIPANT
while ( $i <= $#v )
    # STEP 3: SET UP DIRECTORY PATHS
    set pid = $v[$i]

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/af_l/density.nii.gz --out=${out_dir}/${pid}/tracts/af_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/af_r/density.nii.gz --out=${out_dir}/${pid}/tracts/af_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ar_l/density.nii.gz --out=${out_dir}/${pid}/tracts/ar_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ar_r/density.nii.gz --out=${out_dir}/${pid}/tracts/ar_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ifo_l/density.nii.gz --out=${out_dir}/${pid}/tracts/ifo_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ifo_r/density.nii.gz --out=${out_dir}/${pid}/tracts/ifo_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ilf_l/density.nii.gz --out=${out_dir}/${pid}/tracts/ilf_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/ilf_r/density.nii.gz --out=${out_dir}/${pid}/tracts/ilf_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/slf2_l/density.nii.gz --out=${out_dir}/${pid}/tracts/slf2_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/slf2_r/density.nii.gz --out=${out_dir}/${pid}/tracts/slf2_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/slf3_l/density.nii.gz --out=${out_dir}/${pid}/tracts/slf3_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/slf3_r/density.nii.gz --out=${out_dir}/${pid}/tracts/slf3_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/uf_l/density.nii.gz --out=${out_dir}/${pid}/tracts/uf_l/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz
    applywarp --ref=$MNI_standard --in=${out_dir}/${pid}/tracts/uf_r/density.nii.gz --out=${out_dir}/${pid}/tracts/uf_r/density_mni.nii.gz --warp=${warp_dir}/${pid}/diff2standard.nii.gz

    @ i = $i + 1

    echo ${pid}
end


mkdir ${work_dir}/merged_tractograms
set subjects = (9336 10450 9772 10634 10827 10651 11183 12072 12207 12288 12308 12331 12550 14988 15149 14994 12950 15276)

## GET AF GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/af_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/af_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/af_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/af_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/af_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/af_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/af_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/af_r_averaged_tractogram


## GET AR GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/ar_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/ar_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/ar_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/ar_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/ar_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ar_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/ar_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ar_r_averaged_tractogram


## GET IFO GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/ifo_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/ifo_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/ifo_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/ifo_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/ifo_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ifo_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/ifo_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ifo_r_averaged_tractogram


## GET ILF GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/ilf_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/ilf_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/ilf_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/ilf_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/ilf_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ilf_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/ilf_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/ilf_r_averaged_tractogram


## GET SLF2 GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/slf2_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/slf2_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/slf2_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/slf2_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/slf2_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/slf2_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/slf2_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/slf2_r_averaged_tractogram

## GET SLF3 GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/slf3_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/slf3_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/slf3_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/slf3_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/slf3_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/slf3_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/slf3_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/slf3_r_averaged_tractogram


## GET UF GROUP AVERAGED TRACTOGRAM
set cmd_l = "fslmerge -t  ${work_dir}/merged_tractograms/uf_l_merged_tractograms"
set cmd_r = "fslmerge -t  ${work_dir}/merged_tractograms/uf_r_merged_tractograms"
foreach subject ($subjects)
    set cmd_l = "$cmd_l ${out_dir}/${subject}/tracts/uf_l/density_mni.nii.gz"
    set cmd_r  = "$cmd_r ${out_dir}/${subject}/tracts/uf_r/density_mni.nii.gz"
end
$cmd_l
$cmd_r
fslmaths  ${work_dir}/merged_tractograms/uf_l_merged_tractograms -Tmean ${work_dir}/merged_tractograms/uf_l_averaged_tractogram
fslmaths  ${work_dir}/merged_tractograms/uf_r_merged_tractograms -Tmean ${work_dir}/merged_tractograms/uf_r_averaged_tractogram