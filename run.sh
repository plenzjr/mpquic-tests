#!/bin/bash

START=$(date +"%s")
START_TIME=$(date)
CURRENT_DIR=$(pwd)
PROTOCOLS=('quic' 'tcp')
TYPE_SIM=('Continuous', 'Handover')
SCENARIOS=('Europe_best_case' 'Europe_worst_case' 'Global_best_case' 'Global_worst_case' 'SAmerica_best_case' 'SAmerica_worst_case' 'Usa_best_case' 'Usa_worst_case')

# CREATE MOUNT
scp ./mount_tmpfs.sh mininet@192.168.122.15:/home/mininet
ssh mininet@192.168.122.15 "chmod 777 mount_tmpfs.sh"

count_dirs=0
for t in "${TYPE_SIM[@]}"; do
    for p in "${PROTOCOLS[@]}"; do
        for s in "${SCENARIOS[@]}"; do
            list_of_dirs+="${CURRENT_DIR}/${t}/${s}/${p} ";
            ((count_dirs=count_dirs+1))
        done
    done
done

count=0
echo $count_dirs
for i in ${list_of_dirs[@]}; do
    # ENTER DIR AND PREPARE MINITOPO
    cd $i
    if [[ $i =~ "Handover" ]]; then
        scenario=HANDOVER
        if [[ $i =~ "/quic" ]]; then
            protocol=quic
            cp ${CURRENT_DIR}/2_flows_quic.sh ${CURRENT_DIR}/if_stat_quic.sh ${i}
            ssh mininet@192.168.122.15 "cp ~/git/minitopo/src/mpExperienceQUIC_handover.py ~/git/minitopo/src/mpExperienceQUIC.py"
        else
            cp ${CURRENT_DIR}/2_flows_tcp.sh ${CURRENT_DIR}/if_stat_tcp.sh ${i}
            protocol=tcp
            ssh mininet@192.168.122.15 "cp ~/git/minitopo/src/mpExperienceHTTPS_handover.py ~/git/minitopo/src/mpExperienceHTTPS.py"
        fi
    else
        scenario=CONTINUOUS
        if [[ $i =~ "/quic" ]]; then
            cp ${CURRENT_DIR}/2_flows_quic.sh ${CURRENT_DIR}/if_stat_quic.sh ${i}
            protocol=quic
            ssh mininet@192.168.122.15 "cp ~/git/minitopo/src/mpExperienceQUIC_continuous.py ~/git/minitopo/src/mpExperienceQUIC.py"
        else
            cp ${CURRENT_DIR}/2_flows_tcp.sh ${CURRENT_DIR}/if_stat_tcp.sh ${i}
            protocol=tcp
            ssh mininet@192.168.122.15 "cp ~/git/minitopo/src/mpExperienceHTTPS_continuous.py ~/git/minitopo/src/mpExperienceHTTPS.py"
        fi
    fi

    # CLEAN TMPFS
    ssh mininet@192.168.122.15 "sudo rm -rf /mnt/tmpfs/*"
    ssh mininet@192.168.122.15 "./mount_tmpfs.sh"

    run_starter=$(date +"%s")
    run_start_time=$(date)
    to_run=`expr $count_dirs - $count`
    region=$(echo $i | awk -F'/' '{print $(NF - 1) }')

    echo -e "************************************************************"
    echo -e "###\t\tFALTAM: ${to_run} CENARIOS\t\t###"
    echo -e "ATUALMENTE RODANDO:\t\t $scenario - ${region^^} - ${protocol^^}"
    echo -e "INICIO DA SIMULACAO:\t\t $START_TIME"
    echo -e "INICIANDO TESTE ATUAL:\t\t $run_start_time"
    echo -e "RODANDO ..."


    python3 ./${protocol}.py > /dev/null
    echo -e "CRIANDO ARQUIVOS DE RESULTADOS..."
    ./if_stat_${protocol}.sh > /dev/null
    ./2_flows_${protocol}.sh > /dev/null

    results_dir=${CURRENT_DIR}/results/${scenario,,}/${region,,}/${protocol}

    if [[ ! -d ${results_dir} ]]; then
        mkdir -p ${results_dir}
    fi

    mv ifstat/ *.txt ${results_dir}

    run_end=$(date +"%s")
    run_end_time=$(date)
    total=$((run_end - run_starter))
    echo -e "FINALIZANDO TESTE ATUAL: \t $run_end_time"
    echo -e "FINALIZANDO RODADA APOS: \t" $((total/3600)):$(((total/60)%60)):$((total%60))
    echo -e "************************************************************"


    ((count=count+1))
done

END=$(date +"%s")
TOTAL=$((END - START))
echo -e "############################################################"
echo -e "FINALIZANDO SCRIPT APOS: \t" $((TOTAL/3600)):$(((TOTAL/60)%60)):$((TOTAL%60))
echo -e "############################################################"