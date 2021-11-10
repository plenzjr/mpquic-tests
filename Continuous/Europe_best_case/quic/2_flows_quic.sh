#!/bin/bash


raiz=$(pwd)
protocol=$(pwd | cut -d'/' -f7)
cenario=$(pwd | cut -d'/' -f8)
pasta=$(ls -d */ | grep -v core | grep -v ifstat)
cen=0

echo "Cenario,Band,RTT,Sent,Retrans,Lost,Time" > $raiz/$protocol.$cenario.sp.txt
echo "Cenario,BandA,BandB,RTTA,RTTB,SentA,SentB,Sent,Retrans,Lost,Time" > $raiz/$protocol.$cenario.mp.txt

my_function () {
    if [[ $1 == *[0-9]ms ]]; then
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

    elif [[ $1 == *[0-9]s ]]; then
        sec=$(echo $1 | cut -d '.' -f1)
        ms=$(echo $1 | cut -d '.' -f2 | tr -d s)
        echo "$sec.$ms"
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

        lossA=$(cat $sub/$sub | grep netemAt_0 | cut -d: -f2 | cut -d, -f 2 | cut -d ' ' -f 2 | cut -d'%' -f1)
        lossB=$(cat $sub/$sub | grep netemAt_1 | cut -d: -f2 | cut -d, -f 2 | cut -d ' ' -f 2 | cut -d'%' -f1)

        #DADOS DO CLIENTE CAMINHO UNICO#
        csentU=$(cat $sub/quic/0/quic_client.log | grep Path | cut -d: -f4 | cut -d " " -f3)
        cretrU=$(cat $sub/quic/0/quic_client.log | grep Path | cut -d: -f4 | cut -d " " -f5)
        creceU=$(cat $sub/quic/0/quic_client.log | grep Path | cut -d: -f4 | cut -d " " -f9)
        clossU=$(cat $sub/quic/0/quic_client.log | grep Path | cut -d: -f4 | cut -d " " -f7 | cut -d";" -f1)

        #TEMPO TOTAL ESTA NO CLIENTE PARA O (MP)QUIC
        ctempU=$(cat $sub/quic/0/quic_client.log | tail -n1 | cut -d " " -f3)
        ctimeU=$(my_function $ctempU)

        cpmin1=$(cat $sub/quic/0/ping.log | grep rtt | head -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax1=$(cat $sub/quic/0/ping.log | grep rtt | head -n1 | cut -d"/" -f6)

        cptmp1=$(cat $sub/quic/0/ping.log | grep rtt | head -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg1=$(my_function $cptmp1)

        cpmin2=$(cat $sub/quic/0/ping.log | grep rtt | tail -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax2=$(cat $sub/quic/0/ping.log | grep rtt | tail -n1 | cut -d"/" -f6)

        cptmp2=$(cat $sub/quic/0/ping.log | grep rtt | tail -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg2=$(my_function $cptmp2)

        streamU=$(cat $sub/quic/0/quic_client.log | awk -F 'of' '{print $2}' | sed '/^$/d'| tail -n1)

        #DADOS DO SERVIDOR CAMINHO UNICO#
        ssentU=$(cat $sub/quic/0/quic_server.log | grep -A 1 $streamU | tail -n 1 | cut -d: -f2 | cut -d " " -f3)
        sretrU=$(cat $sub/quic/0/quic_server.log | grep -A 1 $streamU | tail -n 1 | cut -d: -f2 | cut -d " " -f5)
        slossU=$(cat $sub/quic/0/quic_server.log | grep -A 1 $streamU | tail -n 1 | cut -d: -f2 | cut -d " " -f7 | cut -d";" -f1)
        sreceU=$(cat $sub/quic/0/quic_server.log | grep -A 1 $streamU | tail -n 1 | cut -d: -f2 | cut -d " " -f9)

        stempU=$(cat $sub/quic/0/quic_server.log | grep -A 1 $streamU | tail -n 1 | cut -d: -f2 | cut -d " " -f11)
        sdelayU=$(my_function $stempU)

        #DADOS DO CLIENTE MULTICAMINHOS#
        cpmin1m=$(cat $sub/quic/1/ping.log | grep rtt | head -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax1m=$(cat $sub/quic/1/ping.log | grep rtt | head -n1 | cut -d"/" -f6)

        cptmp1m=$(cat $sub/quic/1/ping.log | grep rtt | head -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg1m=$(my_function $cptmp1m)

        cpmin2m=$(cat $sub/quic/1/ping.log | grep rtt | tail -n1 | cut -d"/" -f4 | cut -d" " -f3)
        cpmax2m=$(cat $sub/quic/1/ping.log | grep rtt | tail -n1 | cut -d"/" -f6)

        cptmp2m=$(cat $sub/quic/1/ping.log | grep rtt | head -n1 | tr '/' ' ' |awk -F' ' '{print $8 $11}')
        cpavg2m=$(my_function $cptmp2m)

        csentA=$(cat $sub/quic/1/quic_client.log | grep "Path 1" | tail -n 4 | cut -d: -f4 | cut -d " " -f3)
        cretrA=$(cat $sub/quic/1/quic_client.log | grep "Path 1" | tail -n 4 | cut -d: -f4 | cut -d " " -f5)
        clossA=$(cat $sub/quic/1/quic_client.log | grep "Path 1" | tail -n 4 | cut -d: -f4 | cut -d " " -f7 | cut -d";" -f1)
        creceA=$(cat $sub/quic/1/quic_client.log | grep "Path 1" | tail -n 4 | cut -d: -f4 | cut -d " " -f9)

        csentB=$(cat $sub/quic/1/quic_client.log | grep "Path 3" | tail -n 4 | cut -d: -f4 | cut -d " " -f3)
        cretrB=$(cat $sub/quic/1/quic_client.log | grep "Path 3" | tail -n 4 | cut -d: -f4 | cut -d " " -f5)
        clossB=$(cat $sub/quic/1/quic_client.log | grep "Path 3" | tail -n 4 | cut -d: -f4 | cut -d " " -f7 | cut -d";" -f1)
        creceB=$(cat $sub/quic/1/quic_client.log | grep "Path 3" | tail -n 4 | cut -d: -f4 | cut -d " " -f9)

        ctempM=$(cat $sub/quic/1/quic_client.log | tail -n1 | cut -d " " -f3)
        ctimeM=$(my_function $ctempM)

        streamM=$(cat $sub/quic/1/quic_client.log | awk -F 'of' '{print $2}' | sed '/^$/d' | tail -n 1)

        #DADOS DO SERVIDOR MULTICAMINHOS#
        ssentA=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 1" | cut -d: -f2 | cut -d " " -f3)
        sretrA=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 1" | cut -d: -f2 | cut -d " " -f5)
        slossA=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 1" | cut -d: -f2 | cut -d " " -f7 | cut -d";" -f1)
        sreceA=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 1" | cut -d: -f2 | cut -d " " -f9)

        stempAM=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 1" | cut -d: -f2 | cut -d " " -f11)
        stimeA=$(my_function $stempAM)

        ssentB=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f3)
        sretrB=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f5)
        slossB=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f7 | cut -d";" -f1)
        sreceB=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f9)
        stempB=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f11)

        stempBM=$(cat $sub/quic/1/quic_server.log | grep -A 3 $streamM | tail -n 3 | grep "Path 3" | cut -d: -f2 | cut -d " " -f11)
        stimeB=$(my_function $stempBM)

        cen=$(($cen+1))

        ssentM=$((ssentA+ssentB))
        sretrM=$((sretrA+sretrB))
        slossM=$((slossA+slossB))

        echo -e """
        PARAMETROS DO CENARIO: $cen
        delay caminho A: \t\t\t $delayA
        delay caminho B: \t\t\t $delayB

        banda caminho A: \t\t\t $bandwA
        banda caminho B: \t\t\t $bandwB

        fila  caminho A: \t\t\t $queueA
        fila  caminho B: \t\t\t $queueB

        perda caminho A: \t\t\t $lossA
        perda caminho B: \t\t\t $lossB

        STREAM UNICO: \t\t\t$streamU
        STREAM MULTI: \t\t\t$streamM

        -----------------------------------------

            DADOS DO CLIENTE CAMINHO UNICO
        pacotes enviados: \t\t\t $csentU
        pacotes retransmitidos: \t\t $cretrU
        pacotes perdidos: \t\t\t $clossU
        pacotes recebidos: \t\t\t $creceU
        tempo da conexao: \t\t\t $ctimeU
        PING MIN/MAX/MED \t\t\t $cpmin1 \ $cpmax1 \ $cpavg1
        PING MIN/MAX/MED \t\t\t $cpmin2 \ $cpmax2 \ $cpavg2

        -----------------------------------------

            DADOS DO SERVIDOR CAMINHO UNICO
        pacotes enviados: \t\t\t $ssentU
        pacotes retransmitidos: \t\t $sretrU
        pacotes perdidos: \t\t\t $slossU
        pacotes recebidos: \t\t\t $sreceU

        -----------------------------------------

            DADOS DO CLIENTE MULTICAMINHOS
        pacotes enviados A: \t\t $csentA
        pacotes enviados B: \t\t $csentB

        pacotes retransmitidos A: \t\t $cretrA
        pacotes retransmitidos B: \t\t $cretrB

        pacotes perdidos A: \t\t $clossA
        pacotes perdidos B: \t\t $clossB

        pacotes recebidos A: \t\t $creceA
        pacotes recebidos B: \t\t $creceB
        tempo da conexao AB: \t\t $ctimeM

        PING MIN/MAX/MED \t\t\t $cpmin1m \ $cpmax1m \ $cpavg1m
        PING MIN/MAX/MED \t\t\t $cpmin2m \ $cpmax2m \ $cpavg2m

        -----------------------------------------

            DADOS DO SERVIDOR MULTICAMINHOS
        pacotes enviados A: \t\t $ssentA
        pacotes enviados B: \t\t $ssentB

        pacotes retransmitidos A: \t\t $sretrA
        pacotes retransmitidos B: \t\t $sretrB

        pacotes perdidos A: \t\t $slossA
        pacotes perdidos B: \t\t $slossB

        pacotes recebidos A: \t\t $sreceA
        pacotes recebidos B: \t\t $sreceB

        #######################################################################################################################################
        $dir $sub
        #######################################################################################################################################

    """

        echo "$cen,$bandwA,$cpavg1,$ssentU,$sretrU,$slossU,$ctimeU" >> $raiz/$protocol.$cenario.sp.txt
        echo "$cen,$bandwA,$bandwB,$cpavg1m,$cpavg2m,$ssentA,$ssentB,$ssentM,$sretrM,$slossM,$ctimeM" >> $raiz/$protocol.$cenario.mp.txt
    done
cd $raiz
done
