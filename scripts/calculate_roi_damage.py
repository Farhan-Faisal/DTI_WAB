# Phillip Johnston, 2020
# Farhan Bin Faisal, 2024
# Calculate proportion of overlap between lesion and each ROI

import nibabel as nib
import numpy as np
import os
import pandas as pd


base_directory = '/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract'
atlas_codes_path = os.path.join(base_directory, 'scripts/atlascodes.txt')
stroke_dir = '/rri_disks/artemis/meltzer_lab/tvb_stroke'

pid_list = []
roi_list = []
roi_map = {}


## GET LIST OF PATIENT IDS
with open(os.path.join(base_directory, 'pid.txt'), 'r') as file:
    pid_list = file.readlines()

pid_list = [item.strip('\n') for item in pid_list]

## GET LIST OF ATLAS REGIONS
with open(atlas_codes_path, 'r') as file:
    roi_list = file.readlines()

roi_names = [(item.split(':')[1]).strip('\n').strip().split('...')[0] for item in roi_list]
roi_list = [(item.split(':')[2]).strip('\n').strip() for item in roi_list]

for i, number in enumerate(roi_list):
    roi_map[number] = roi_names[i]


output_dict = []
for pid in pid_list:
    csf = nib.load(stroke_dir + '/' + pid + "/anat/" + pid + "_anat_brain_seg_0.nii.gz")
    csf_data = csf.get_data()
    gm = nib.load(stroke_dir + '/' + pid + "/anat/" + pid + "_anat_brain_seg_1.nii.gz")
    gm_data = gm.get_data()
    wm = nib.load(stroke_dir + '/' + pid + "/anat/" + pid + "_anat_brain_seg_2.nii.gz")
    wm_data = wm.get_data()

    # import lesionmask data
    lm = nib.load(base_directory + '/atlas_language_roi/' + pid + '/lesionmask.nii')
    lm_data = np.asanyarray(lm.dataobj)

    # import warped AAL atlas and change to int
    warped_aal = nib.load(base_directory + '/atlas_language_roi/' + pid + '/' + pid + '_T1_atlas.nii.gz')
    warped_aal_data = np.asanyarray(warped_aal.dataobj)
    warped_aal_data = warped_aal_data.astype('int32')

    # copy header from anat file 
    anat_img = nib.load(base_directory + '/atlas_language_roi/' + pid + '/' + pid + '_mprage.nii.gz')
    header_copy = anat_img.header.copy()

    # multiply masks to find overlap
    csf_data =  np.multiply(warped_aal_data, csf_data)
    gm_data =  np.multiply(warped_aal_data, gm_data)
    wm_data =  np.multiply(warped_aal_data, wm_data)

    lesion_overlap = np.multiply(warped_aal_data, lm_data)
    csf_overlap = np.multiply(lesion_overlap, csf_data)
    gm_overlap = np.multiply(lesion_overlap, gm_data) 
    wm_overlap = np.multiply(lesion_overlap, wm_data)
    
    # save lesion overlap as nifti for inspection
    nib.save(nib.nifti1.Nifti1Image(lesion_overlap, None, header=header_copy), base_directory + '/atlas_language_roi/' + pid + '/' + pid + '_overlap.nii.gz')
    nib.save(nib.nifti1.Nifti1Image(csf_overlap, None, header=header_copy), base_directory + '/atlas_language_roi/' + pid + '/' + pid  + "_csf_overlap.nii")
    nib.save(nib.nifti1.Nifti1Image(gm_overlap, None, header=header_copy), base_directory + '/atlas_language_roi/' + pid + '/' + pid  + "_gm_overlap.nii")
    nib.save(nib.nifti1.Nifti1Image(wm_overlap, None, header=header_copy), base_directory + '/atlas_language_roi/' + pid + '/' + pid + "_wm_overlap.nii")

    # calculate lesion overlap

    ## GET OVERLAP WITH TEMPORAL LOBE REGIONS
    # l:Left Heschls Gyrus................................:79 
    # l:Left Superior Temporal Gyrus......................:81 
    # l:Left Temporal Pole................................:83 
    # l:Left Middle Temporal Gyrus........................:85 
    # l:Left Medial Temporal Pole.........................:87 
    # l:Left Inferior Temporal Gyrus......................:89 

    temporal_rois = [float(79), float(83), float(85), float(87)]
    condition = np.logical_or.reduce([warped_aal_data == value for value in temporal_rois])
    temporal_total_voxels = np.count_nonzero(condition)
    temporal_total_gm_voxels = np.count_nonzero(np.logical_or.reduce([gm_data == value for value in temporal_rois]))
    temporal_total_wm_voxels = np.count_nonzero(np.logical_or.reduce([wm_data == value for value in temporal_rois]))
    temporal_total_csf_voxels = np.count_nonzero(np.logical_or.reduce([csf_data == value for value in temporal_rois]))

    in_lesion = np.count_nonzero(np.logical_or.reduce([lesion_overlap == value for value in temporal_rois]))
    in_csf = np.count_nonzero(np.logical_or.reduce([csf_overlap == value for value in temporal_rois]))
    in_gm = np.count_nonzero(np.logical_or.reduce([gm_overlap == value for value in temporal_rois]))
    in_wm = np.count_nonzero(np.logical_or.reduce([wm_overlap == value for value in temporal_rois]))

    temporal_percent_overlap = np.around(np.true_divide(in_lesion, temporal_total_voxels), 4)
    temporal_gm_percent_overlap = np.around(np.true_divide(in_gm, temporal_total_gm_voxels), 4)
    temporal_wm_percent_overlap = np.around(np.true_divide(in_wm, temporal_total_wm_voxels), 4)
    temporal_csf_percent_overlap = np.around(np.true_divide(in_csf, temporal_total_csf_voxels), 4)


    ## PARIETAL LOBE REGIONS
    # l:Left Superior Parietal Lobule.....................:59 
    # l:Left Inferior Parietal Lobule.....................:61 
    # l:Left SupraMarginal Gyrus..........................:63 
    # l:Left Angular Gyrus................................:65 
    parietal_rois = [float(59), float(61), float(63), float(65)]
    condition = np.logical_or.reduce([warped_aal_data == value for value in parietal_rois])
    parietal_total_voxels = np.count_nonzero(condition)
    parietal_total_gm_voxels = np.count_nonzero(np.logical_or.reduce([gm_data == value for value in parietal_rois]))
    parietal_total_wm_voxels = np.count_nonzero(np.logical_or.reduce([wm_data == value for value in parietal_rois]))
    parietal_total_csf_voxels = np.count_nonzero(np.logical_or.reduce([csf_data == value for value in parietal_rois]))


    in_lesion = np.count_nonzero(np.logical_or.reduce([lesion_overlap == value for value in parietal_rois]))
    in_csf = np.count_nonzero(np.logical_or.reduce([csf_overlap == value for value in parietal_rois]))
    in_gm = np.count_nonzero(np.logical_or.reduce([gm_overlap == value for value in parietal_rois]))
    in_wm = np.count_nonzero(np.logical_or.reduce([wm_overlap == value for value in parietal_rois]))

    parietal_percent_overlap = np.around(np.true_divide(in_lesion, parietal_total_voxels), 4)
    parietal_gm_percent_overlap = np.around(np.true_divide(in_gm, parietal_total_gm_voxels), 4)
    parietal_wm_percent_overlap = np.around(np.true_divide(in_wm, parietal_total_wm_voxels), 4)
    parietal_csf_percent_overlap = np.around(np.true_divide(in_csf, parietal_total_csf_voxels), 4)

    ## INFERIOR FRONTAL LOBE REGIONS
    # l:Left Inferior Frontal Gyrus (p. Opercularis)......:11 
    # l:Left Inferior Frontal Gyrus (p. Triangularis).....:13 
    # l:Left Inferior Frontal Gyrus (p. Orbitalis)........:15 
    # l:Left Insula Lobe..................................:29 
    frontal_rois = [float(11), float(13), float(15), float(29)]
    condition = np.logical_or.reduce([warped_aal_data == value for value in frontal_rois])
    frontal_total_voxels = np.count_nonzero(condition)
    frontal_total_gm_voxels = np.count_nonzero(np.logical_or.reduce([gm_data == value for value in frontal_rois]))
    frontal_total_wm_voxels = np.count_nonzero(np.logical_or.reduce([wm_data == value for value in frontal_rois]))
    frontal_total_csf_voxels = np.count_nonzero(np.logical_or.reduce([csf_data == value for value in frontal_rois]))

    in_lesion = np.count_nonzero(np.logical_or.reduce([lesion_overlap == value for value in frontal_rois]))
    in_csf = np.count_nonzero(np.logical_or.reduce([csf_overlap == value for value in frontal_rois]))
    in_gm = np.count_nonzero(np.logical_or.reduce([gm_overlap == value for value in frontal_rois]))
    in_wm = np.count_nonzero(np.logical_or.reduce([wm_overlap == value for value in frontal_rois]))

    frontal_percent_overlap = np.around(np.true_divide(in_lesion, frontal_total_voxels), 4)
    frontal_gm_percent_overlap = np.around(np.true_divide(in_gm, frontal_total_gm_voxels), 4)
    frontal_wm_percent_overlap = np.around(np.true_divide(in_wm, frontal_total_wm_voxels), 4)
    frontal_csf_percent_overlap = np.around(np.true_divide(in_csf, frontal_total_csf_voxels), 4)

    ## MOTOR CORTEX REGIONS
    # l:Left Precentral Gyrus.............................:1  
    # l:Left Rolandic Operculum...........................:17 
    # l:Left SMA..........................................:19 
    # l:Left Postcentral Gyrus............................:57 
    motor_rois = [float(1), float(17), float(19), float(57)]
    condition = np.logical_or.reduce([warped_aal_data == value for value in motor_rois])
    motor_total_voxels = np.count_nonzero(condition)
    motor_total_gm_voxels = np.count_nonzero(np.logical_or.reduce([gm_data == value for value in motor_rois]))
    motor_total_wm_voxels = np.count_nonzero(np.logical_or.reduce([wm_data == value for value in motor_rois]))
    motor_total_csf_voxels = np.count_nonzero(np.logical_or.reduce([csf_data == value for value in motor_rois]))
    

    in_lesion = np.count_nonzero(np.logical_or.reduce([lesion_overlap == value for value in motor_rois]))
    in_csf = np.count_nonzero(np.logical_or.reduce([csf_overlap == value for value in motor_rois]))
    in_gm = np.count_nonzero(np.logical_or.reduce([gm_overlap == value for value in motor_rois]))
    in_wm = np.count_nonzero(np.logical_or.reduce([wm_overlap == value for value in motor_rois]))

    motor_percent_overlap = np.around(np.true_divide(in_lesion, motor_total_voxels), 4)
    motor_gm_percent_overlap = np.around(np.true_divide(in_gm, motor_total_gm_voxels), 4)
    motor_wm_percent_overlap = np.around(np.true_divide(in_wm, motor_total_wm_voxels), 4)
    motor_csf_percent_overlap = np.around(np.true_divide(in_csf, motor_total_csf_voxels), 4)

    entry = {
                'pid': pid,
                'temporal': temporal_percent_overlap,
                'temporal_gm': temporal_gm_percent_overlap,
                'temporal_wm': temporal_wm_percent_overlap,
                'temporal_csf': temporal_csf_percent_overlap,
                'parietal': parietal_percent_overlap,
                'parietal_gm': parietal_gm_percent_overlap,
                'parietal_wm': parietal_wm_percent_overlap,
                'parietal_csf': parietal_csf_percent_overlap,
                'frontal': frontal_percent_overlap,
                'frontal_gm': frontal_gm_percent_overlap,
                'frontal_wm': frontal_wm_percent_overlap,
                'frontal_csf': frontal_csf_percent_overlap,
                'motor': motor_percent_overlap,
                'motor_gm': motor_gm_percent_overlap,
                'motor_wm': motor_wm_percent_overlap,
                'motor_csf': motor_csf_percent_overlap
             }

    output_dict.append(entry)

DF = pd.DataFrame.from_dict(output_dict)
DF.to_csv('/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract/tables/' + 'roi_damage.csv')
print(DF)