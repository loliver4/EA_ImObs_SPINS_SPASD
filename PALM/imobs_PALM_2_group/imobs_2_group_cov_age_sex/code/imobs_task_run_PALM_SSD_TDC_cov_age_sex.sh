#!/bin/bash
#SBATCH --partition=high-moby
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2G
#SBATCH --time=12:00:00
#SBATCH --export=ALL
#SBATCH --job-name PALM
#SBATCH --output=/projects/imoxonemre/SPIN_ASD/imobs_PALM_2_group/imobs_2_group_cov_age_sex/PALM_logs/PALM_SSD_TDC_imobs_task_cov_age_sex%j.txt
#SBATCH --error=/projects/imoxonemre/SPIN_ASD/imobs_PALM_2_group/imobs_2_group_cov_age_sex/PALM_logs/PALM_SSD_TDC_imobs_task_cov_age_sex%jerr.txt
#SBATCH --array=1

module load matlab/R2017b
module load palm/alpha111
module load connectome-workbench/1.3.2

# assign the current directory variable and paths to the filielist and sublist for this analysis

DIR="/projects/imoxonemre/SPIN_ASD/imobs_PALM_2_group/imobs_2_group_cov_age_sex"

sublistids="${DIR}/subids/SSD_TDC_sublist_imobs.txt"
filename="$(find $DIR/filelists/SSD_TDC/filelist* -type f | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)"
truncname="$(echo $(basename `echo "$filename"`) | sed 's/filelist/SSD_TDC/;s/.txt//')"
outdir="${DIR}/results/$truncname"
# need a contrast and design matrix this time
desmat="$DIR/con_design/SSD_TDC_imobs_task_design_cov_age_sex.csv"
conmat="$DIR/con_design/2_group_imobs_task_contrast_cov_age_sex.csv"

#outdir is the place where users want to save results in
echo output directory is $outdir
mkdir -p $outdir
cd $outdir

# Using wildcards becuase ciftify files are in the SPINS and SPASD bids folders respectively - so need to point to both at the same time
HCP_DATA=/archive/data/SP*/pipelines/bids_apps/ciftify/sub*


infile=allsubs_merged.dscalar.nii
fname=merge_split
#extracting the first element of sublistids file
exampleSubid=$(head -n 1 ${sublistids})
#first Instance of sublistids file
surfL=${HCP_DATA}/MNINonLinear/fsaverage_LR32k/${exampleSubid}.L.midthickness.32k_fs_LR.surf.gii
surfR=${HCP_DATA}/MNINonLinear/fsaverage_LR32k/${exampleSubid}.R.midthickness.32k_fs_LR.surf.gii


#stage 1 merge files (do a while loop reading a text file with a lsit of cifti files
mergefiles() {
    args=""
    while read ff
    do
	args="${args} -cifti $ff"
    done < ${filename} #specify the full path for filename file
    echo $args

    # allsubs_merged.dscalar.nii is the file that PALM will use
    wb_command -cifti-merge ${infile} ${args}
}


#stage 2 separate cifti into gifti
cifti2gifti() {
    wb_command -cifti-separate $infile COLUMN -volume-all ${fname}_sub.nii -metric CORTEX_LEFT ${fname}_L.func.gii -metric CORTEX_RIGHT ${fname}_R.func.gii
    wb_command -gifti-convert BASE64_BINARY ${fname}_L.func.gii ${fname}_L.func.gii
    wb_command -gifti-convert BASE64_BINARY ${fname}_R.func.gii ${fname}_R.func.gii
}

#stage 3 Calculate mean surface
meansurface() {
    MERGELIST=""
    while read subids; do
	  #dir=${HCP_DATA}/MNINonLinear/fsaverage_LR32k
	  va_dir=/projects/imoxonemre/SPIN_ASD/PALM_Nov2021/va_files/
	  MERGELIST="${MERGELIST} -metric $va_dir/${subids}.L.midthick_va.shape.gii";
    done < ${sublistids}

    #wb_command will automatically save results in the current dir, which is outdir
    wb_command -metric-merge L_midthick_va.func.gii ${MERGELIST}
    wb_command -metric-reduce L_midthick_va.func.gii MEAN L_area.func.gii

    MERGELIST=""
    while read subids; do
	  #dir=${HCP_DATA}/MNINonLinear/fsaverage_LR32k
	  va_dir=/projects/imoxonemre/SPIN_ASD/PALM_Nov2021/va_files/
	  MERGELIST="${MERGELIST} -metric $va_dir/${subids}.R.midthick_va.shape.gii";
    done < ${sublistids}

    wb_command -metric-merge R_midthick_va.func.gii ${MERGELIST}
    wb_command -metric-reduce R_midthick_va.func.gii MEAN R_area.func.gii
}

#stage 4: RUN PALM

runpalm() {
    palm -i ${fname}_L.func.gii -d $desmat -t $conmat -o results_L_cort -T -tfce2D -s $surfL L_area.func.gii -logp -n 1000 -ise -precision "double"
    palm -i ${fname}_R.func.gii -d $desmat -t $conmat -o results_R_cort -T -tfce2D -s $surfR R_area.func.gii -logp -n 1000 -ise -precision "double"
    palm -i ${fname}_sub.nii -d $desmat -t $conmat -o results_sub -T -logp -n 1000 -ise -precision "double"

    # C1 = SSD > TDC; C2 = TDC > SSD; C3 = positive age; c4 = negative age; C5 = positive sex; C6 = negative sex
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c1.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c1.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c1.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c1.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c2.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c2.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c2.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c2.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c3.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c3.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c3.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c3.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c4.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c4.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c4.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c4.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c5.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c5.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c5.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c5.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c6.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c6.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c6.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c6.gii

    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c12.dscalar.nii -var x results_cort_tfce_tstat_fwep_c1.dscalar.nii -var y results_cort_tfce_tstat_fwep_c2.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c34.dscalar.nii -var x results_cort_tfce_tstat_fwep_c3.dscalar.nii -var y results_cort_tfce_tstat_fwep_c4.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c56.dscalar.nii -var x results_cort_tfce_tstat_fwep_c5.dscalar.nii -var y results_cort_tfce_tstat_fwep_c6.dscalar.nii

}

#back to the previous directory

mergefiles &&
    cifti2gifti &&
    meansurface &&
    runpalm
