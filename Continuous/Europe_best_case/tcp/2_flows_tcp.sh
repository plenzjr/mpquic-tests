#!/bin/bash

raiz=$(pwd)
protocol=$(pwd | cut -d'/' -f7)
cenario=$(pwd | cut -d'/' -f8)
pasta=$(ls -d */ | grep -v core | grep -v ifstat)
cen=0


echo "Cenario,Band,RTT,Sent,Retrans,Lost,Time" > $raiz/$protocol.$cenario.sp.txt
echo "Cenario,BandA,BandB,RTTA,RTTB,Sent,Retrans,Lost,Time" > $raiz/$protocol.$cenario.mp.txt

my_function () {
    if [[ $1 == *ms ]]; then
        echo "$1" | tr -d . | tr -d ms | sed 's/^/0./'
    elif [[ $1 == [0-9].* ]]; then
        echo "$1" | tr -d s
    elif [[ $1 == [0-9]m.* ]]; then
        mult=$(echo $1 | cut -d '.' -f1 | tr -d m)
        TotalSecond=$(($mult*60))
        ms=$(echo $1 | cut -d '.' -f2 | tr -d s)
        echo "$TotalSecond.$ms"
    elif [[ $1 == [0-9]m[0-9].* ]]; then
        mult=$(echo $1 | cut -d 'm' -f1)
        sec=$(echo $1 | cut -d 'm' -f2 | cut -d '.' -f1)
        TotalSecond=$((($mult*60)+$sec))
        ms=$(echo $1 | cut -d '.' -f2 | tr -d s)
        echo "$TotalSecond.$ms"
    elif [[ $1 == [0-9]m[0-9][0-9].* ]]; then
        mult=$(echo $1 | cut -d 'm' -f1)
        sec=$(echo $1 | cut -d 'm' -f2 | cut -d '.' -f1)
        TotalSecond=$((($mult*60)+$sec))
        ms=$(echo $1 | cut -d '.' -f2 | tr -d s)
        echo "$TotalSecond.$ms"
    fi
}

for dir in $pasta
do
    cd $dir
    ins=$(ls | cut -d' ' -f 9)

    for sub in $ins
    do
        #DADOS DA CONEXAO#
        delayA=$(cat $sub/$sub | grep path_0 | cut -d: -f2 | cut -d, -f 1)
        delayB=$(cat $sub/$sub | grep path_1 | cut -d: -f2 | cut -d, -f 1)
        bandwA=$(cat $sub/$sub | grep path_0 | cut -d: -f2 | cut -d, -f 3)
        bandwB=$(cat $sub/$sub | grep path_1 | cut -d: -f2 | cut -d, -f 3)
        queueA=$(cat $sub/$sub | grep path_0 | cut -d: -f2 | cut -d, -f 2)
        queueB=$(cat $sub/$sub | grep path_1 | cut -d: -f2 | cut -d, -f 2)
        clossA=$(cat $sub/$sub | grep At_0 | awk '{print $2}')
        clossB=$(cat $sub/$sub | grep At_1 | awk '{print $2}')

        cpmin1=$(cat $sub/https/0/ping.log | grep rtt | head -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax1=$(cat $sub/https/0/ping.log | grep rtt | head -n1 | cut -d"/" -f6)

        cptmp1=$(cat $sub/https/0/ping.log | grep rtt | head -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg1=$(my_function $cptmp1)

        cpmin2=$(cat $sub/https/0/ping.log | grep rtt | tail -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax2=$(cat $sub/https/0/ping.log | grep rtt | tail -n1 | cut -d"/" -f6)

        cptmp2=$(cat $sub/https/0/ping.log | grep rtt | tail -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg2=$(my_function $cptmp2)


        #DADOS DO CLIENTE CAMINHO UNICO#
        creceU=$(cat $sub/https/0/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 7 {print $1}')
        csentU=$(cat $sub/https/0/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 8 {print $1}')
        cretrU=$(cat $sub/https/0/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 9 {print $1}')

        #TEMPO TOTAL ESTA NO CLIENTE PARA O (MP)TCP
        ctempU=$(cat $sub/https/0/https_client.log | grep real | awk '{print $2}')
        ctimeU=$(my_function $ctempU)

        #DADOS DO SERVIDOR CAMINHO UNICO#
        sreceU=$(cat $sub/https/0/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 7 {print $1}')
        ssentU=$(cat $sub/https/0/netstat_server_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 8 {print $1}')
        sretrU=$(cat $sub/https/0/netstat_server_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 9 {print $1}')
        slossU=$(cat $sub/https/0/netstat_server_after | egrep -i -A 10 'TcpExt\:' | grep loss | head -n 1 | awk -F' ' '{print $1}')

        #DADOS DO CLIENTE MULTICAMINHOS#
        creceM=$(cat $sub/https/1/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 7 {print $1}')
        csentM=$(cat $sub/https/1/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 8 {print $1}')
        cretrM=$(cat $sub/https/1/netstat_client_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 9 {print $1}')

        #TEMPO TOTAL ESTA NO CLIENTE PARA O (MP)TCP
        ctempM=$(cat $sub/https/1/https_client.log | grep real | awk '{print $2}')
        ctimeM=$(my_function $ctempM)
        ######
        # ctimeU=$(cat $sub/https/1/https_client.log | grep real | awk '{print $2}')

        cpmin1m=$(cat $sub/https/1/ping.log | grep rtt | head -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax1m=$(cat $sub/https/1/ping.log | grep rtt | head -n1 | cut -d"/" -f6)

        cptmp1m=$(cat $sub/https/1/ping.log | grep rtt | head -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg1m=$(my_function $cptmp1m)


        cpmin2m=$(cat $sub/https/1/ping.log | grep rtt | tail -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax2m=$(cat $sub/https/1/ping.log | grep rtt | tail -n1 | cut -d"/" -f6)

        cptmp2m=$(cat $sub/https/1/ping.log | grep rtt | tail -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg2m=$(my_function $cptmp2m)

        #DADOS DO SERVIDOR MULTICAMINHOS#
        sreceM=$(cat $sub/https/1/netstat_server_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 7 {print $1}')
        ssentM=$(cat $sub/https/1/netstat_server_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 8 {print $1}')
        sretrM=$(cat $sub/https/1/netstat_server_after | egrep -i -A 10 'tcp\:' | awk 'FNR == 9 {print $1}')
        slossM=$(cat $sub/https/1/netstat_server_after | egrep -i -A 10 'TcpExt\:' | grep loss | head -n 1 | awk -F' ' '{print $1}')

        cen=$(($cen+1))

        echo -e """
        #       PARAMETROS DO CENARIO: $cen
        #    delay caminho A: \t\t\t\t $delayA
        #    delay caminho B: \t\t\t\t $delayB
        #    banda caminho A: \t\t\t\t $bandwA
        #    banda caminho B: \t\t\t\t $bandwB
        #    fila  caminho A: \t\t\t\t $queueA
        #    fila  caminho B: \t\t\t\t $queueB
        #    perda caminho A: \t\t\t\t $clossA
        #    perda caminho B: \t\t\t\t $clossB
        #    diretorio: \t\t\t\t $sub
        #    -----------------------------------------
        #       DADOS DO CLIENTE CAMINHO UNICO
        #    pacotes enviados: \t\t\t\t $csentU
        #    pacotes retransmitidos: \t\t\t $cretrU
        #    pacotes recebidos: \t\t\t $creceU
        #    tempo da conexao: \t\t\t\t $ctimeU
        #    -----------------------------------------
        #       DADOS DO SERVIDOR CAMINHO UNICO
        #    pacotes enviados: \t\t\t\t $ssentU
        #    pacotes retransmitidos: \t\t\t $sretrU
        #    pacotes recebidos: \t\t\t $sreceU
        #   -----------------------------------------
        #       DADOS DO CLIENTE MULTICAMINHOS
        #    pacotes enviados: \t\t\t\t $csentM
        #    pacotes retransmitidos: \t\t\t $cretrM
        #    pacotes recebidos: \t\t\t $creceM
        #    tempo da conexao: \t\t\t\t $ctimeM
        #    -----------------------------------------
        #       DADOS DO SERVIDOR CAMINHO UNICO
        #    pacotes enviados: \t\t\t\t $ssentM
        #    pacotes retransmitidos: \t\t\t $sretrM
        #    pacotes recebidos: \t\t\t $sreceM
        #   -----------------------------------------

        """

        echo "${cen},${bandwA},${cpavg1},${ssentU},${sretrU},${slossU},${ctimeU}" >> ${raiz}/${protocol}.${cenario}.sp.txt
        echo "${cen},${bandwA},${bandwB},${cpavg1m},${cpavg2m},${ssentM},${sretrM},${slossM},${ctimeM}" >> ${raiz}/${protocol}.${cenario}.mp.txt
    done
    cd $raiz
done
