#!/bin/bash


raiz=$(pwd)
pasta=$(ls -d */ | grep -v core | grep -v ifstat | grep -v ifstat)
saida="$raiz/ifstat"

if [ ! -d "$saida" ]; then
    mkdir $saida
else
    rm -rf $saida/*
fi

cen=1
aux=1

for dir in $pasta
do
    cd $dir
    ins=$(ls | cut -d' ' -f 9)

    for sub in $ins
    do
        FILE=$saida/mp_ifstat_${cen}_${aux}.txt
        if [ ! -f $FILE ]; then
            touch $FILE
            echo "time,eth0-in,eth0-out,eth1-in,eth1-out" > $FILE
        fi

        cat $sub/quic/1/client_ifstat.txt | sed '/KB\/s/g' | sed '/Clie/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]\{1,\}/,/g' | sed -r '/^\s*$/d' >> $FILE
        aux=$((aux+1))
    done
    cen=$((cen+1))
    aux=1
    cd $raiz
done

cen=1
aux=1

for dir in $pasta
do
    cd $dir
    ins=$(ls | cut -d' ' -f 9)

    for sub in $ins
    do
        FILE=$saida/sp_ifstat_${cen}_${aux}.txt
        if [ ! -f $FILE ]; then
            touch $FILE
            echo "time,eth0-in,eth0-out,eth1-in,eth1-out" > $FILE
        fi

        cat $sub/quic/0/client_ifstat.txt | sed '/KB\/s/g' | sed '/Clie/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]\{1,\}/,/g' | sed -r '/^\s*$/d' >> $FILE
        aux=$((aux+1))
    done
    cen=$((cen+1))
    aux=1
    cd $raiz
done
