# 20 full runs on anyonwiki centers for rank <= 3.
#
# Start with
#
# screen -S rank_le_3 -L -Logfile rank_le_3.log sh rank_le_3.sh
#
for i in $(seq 1 20); do
    julia --project=~/julia-envs/dev rank_le_3.jl
done
