#!/bin/bash

START=$(date +"%s")
START_TIME=$(date)
CURRENT_DIR=$(pwd)
PROTOCOLS=('quic' 'tcp')
TYPE_SIM=('Continuous')
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
        else
            protocol=tcp
        fi
    else
        scenario=CONTINUOUS
        if [[ $i =~ "/quic" ]]; then
            protocol=quic
        else
            protocol=tcp
        fi
    fi

    # CLEAN TMPFS
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

    results_dir=${CURRENT_DIR}/results/

    if [[ -d ${results_dir} ]]; then
        rm -rf ${results_dir}
    fi

    rm -rf ifstat/ *.txt https*

done