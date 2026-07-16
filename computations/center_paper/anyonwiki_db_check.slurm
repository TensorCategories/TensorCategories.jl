#!/bin/bash
#
# Start with 
# 
# sbatch --array=1-250%20 computations/center_paper/anyonwiki_db_check.slurm
#

#SBATCH --job-name=anyonwiki_db_check
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16384
#SBATCH --time=08:00:00
#SBATCH --output=slurm_logs/anyonwiki-%A_%a.out
#SBATCH --error=slurm_logs/anyonwiki-%A_%a.err

set -euo pipefail

cd "$SLURM_SUBMIT_DIR"

export JULIA_NUM_THREADS="$SLURM_CPUS_PER_TASK"

#"$HOME/bin/tc" \
#    computations/center_paper/anyonwiki_db_check.jl \
#   "$SLURM_ARRAY_TASK_ID"

"$HOME/bin/jlrel" \
    computations/center_paper/anyonwiki_db_check.jl \
    "$SLURM_ARRAY_TASK_ID"