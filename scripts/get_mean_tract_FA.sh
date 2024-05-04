#!/bin/tcsh

# Set FSL environment variables
setenv FSLDIR /software/fsl
setenv PATH ${FSLDIR}/bin:${PATH}
source ${FSLDIR}/etc/fslconf/fsl.csh

# Define paths to your data
set work_dir = /rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract
set tract_dir = ${work_dir}/all_tracts
set data_dir = /rri_disks/artemis/meltzer_lab/tvb_stroke
set output_dir =  ${work_dir}/tables

# MAKE THE OUTPUT FILE
mkdir ${output_dir}
touch ${output_dir}/mean_tract_FA.csv

# INITIALIZE HEADERS
echo "pid,tract,mean_FA" > ${output_dir}/mean_tract_FA.csv

# Loop through each participant
set subjects = (9336 10450 9772 10634 10827 10651 11183 12072 12207 12288 12308 12331 12550 14988 15149 14994 12950 15276)
set tracts = ("af_l" "af_r" "ilf_l" "ilf_r" "ar_l" "ar_r" "ifo_l" "ifo_r" "slf3_l" "slf3_r" "uf_l" "uf_r")

foreach participant ($subjects)
    echo "Processing participant $participant"

    # THIS IS THE FA MAP
    set fa_map  = ${data_dir}/${participant}/dwi/dti_FA.nii.gz

    # LOOP THROUGH EACH TRACT
    foreach tract ($tracts)
        echo "Extracting mean FA for tract $tract"

        # Load tract mask
        set tract_mask = ${tract_dir}/${participant}/tracts/${tract}/density.nii.gz

        # Use FSL's fslstats to calculate mean FA within the tract mask
        set mean_fa = `fslstats $fa_map -k $tract_mask -M`

        # Output the result to the CSV file
        echo "$participant,$tract,$mean_fa" >> ${output_dir}/mean_tract_FA.csv
    end
end

echo "Processing complete."
