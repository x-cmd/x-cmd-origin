# shellcheck shell=sh disable=SC3043

# cloudfront


# shellcheck shell=sh disable=SC3043

ali_config_ak(){
    local PROFILE=${1:?"Provide Profile"}
    local ID=${1:?"Provide AccessKey ID"}
    local KEY=${2:?"Provide AccessKey Secret"}
    local REGION=${3:?"cn-shenzhen"}

    aliyun configure set \
        --profile "$PROFILE" \
        --language en \
        --region "$REGION" \
        --mode AK \
        --access-key-id "$ID" \
        --access-key-secret "$KEY"
}
# shellcheck shell=sh disable=SC3043

ali_disk(){
    param:dsl <<A
subcommand:
    ls              "list"
    exact           "eaxct"
    exactid         "exactid"
A
    param:run
  
    if [ -z "$PARAM_SUBCMD" ]; then
        ali_disk_quick "$@"
        return
    fi

    "ali_disk_$PARAM_SUBCMD" "$@"
}


ali_disk_quick(){
    param:void
    ali_disk_ls "$@"
}

ali_disk_ls(){
    param:void
    _ali_disk_ls "$@" | {
        if [ ! -t 1 ]; then
            cat
            return
        fi

        ali_table_json \
            id=.DiskId charge=.DiskChargeType .RegionId .InstanceId .Size .Status .Category .Device
    }
}

_ali_disk_ls(){
    param:void
    case $# in
        0)  ccmd 1s -- aliyun ecs DescribeDisks | x jq .Disks.Disk
            ;;
        *)  _ali_disk_ls | x jq "
                .[] | 
                if      .DiskId | test(\"$1\")          then .
                elif    .DiskName | test(\"$1\")        then .
                else    empty end
            " | x jq -s .
            ;;
    esac

}

ali_exactor_declare ali_disk "No such disk found." "Multiple disk found" DiskId

ali_disk_quick(){
    ali_quicker2 disk
}
# shellcheck shell=sh disable=SC3043

xrc ali/_v0/dns_record
xrc ali/_v0/dns_domain


# ali dns lteam.top =lteamtop
# ali dns www.lteam.top =www_record   # Using variable

# ali dns www.lteam.top 48.1.1.1

# ali dns domain ls
# ali dns domain ls 
# ali dns --domain www.lteam.top --record 48.1.1.1


# help doc: 'ali dns' is alias for 'ali dns quick'
ali_dns(){
    param:dsl <<A
subcommand:
    domain          "handle_domains"
    record|rec      "handling record"
    ls              "list"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_dns_quick "$@"
        return
    fi

    "ali_dns_$PARAM_SUBCMD" "$@"
}

ali_dns_ls(){
    param:void

    if [ $# = 0 ]; then
        # ali_dns_domain_list
        ali_dns_record_ls
        return
    fi

    local name=$1
    if [ "$name" = "${name%.*.*.}" ]; then
        ali_dns_record_ls "$name"
    else
        ali_dns_domain_ls "$name"
    fi
}


# ali dns a.lteam.top 192.168.1.1
# ali dns b.lteam.top b.lteam.top

# ali dns lteam.top             > show information of domain
# ali dns a.lteam.top           > show information of this record

ali_dns_quick(){
    param:void

    if [ "$1" = _x_cmd_advise_json ]; then
        cat <<A
{}
A
        return 126
    fi

    case $# in
        0)  ali dns domain
            return 0
            ;;
        1)  ali dns record "$@"
            case "$1" in
                :*)   ali_dns_record_del "${1#:}" ;;
                # *)    ali_dns_ls "$1"      ;;
                *)      ali_dns_record "$1" ;;
            esac
            return
            ;;
        2)
            local name=$1
            ali_dns_record_put "$name" "$2"
            ali dns record "$name"
            ;;
        *)  ali dns record "$@"
            ;;
    esac
}
# shellcheck shell=sh disable=SC3043

ali_dns_domain(){
    param:dsl <<A
subcommand:
    ls|list     "list all records"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_dns_domain_quick "$@"
        return
    fi

    ali_dns_domain_"$PARAM_SUBCMD" "$@"
}

ali_dns_domain_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_dns_domain_ls "$@"
        return
    fi
    
    _ali_dns_domain_ls "$@" \
        | ali_table_json \
            .DomainId .DomainName .RecordCount .AliDomain .CreateTime
}

# shellcheck disable=SC2120
_ali_dns_domain_ls(){
    param:void
    case $# in
        0)  aliyun alidns DescribeDomains | x jq .Domains.Domain
            ;;
        *)  _ali_dns_domain_ls | x jq "
                .[] | 
                if .DomainName | test(\"$1\")      then .
                elif .DomainId | test(\"$1\")      then .
                else empty end
            " | x jq -s .
            ;;
    esac
}

ali_dns_domain_exact_id(){
    param:void
    local s
    s="$(_ali_dns_domain_ls "${1:-Provide ip}")"
    local len
    len="$(echo "$s" | x jq ' . | length ')"
    case $len in
        0)  ali_log warn "No such ip found.";;
        1)  echo "$s" | x jq -r .AllocationId
            return 0
            ;;
        *)  ali_log warn "Multiple ip found.";;
    esac
    return 1
}

ali_dns_domain_quick(){
    ali_quicker2 dns domain
}

# shellcheck shell=sh disable=SC3043

ali_dns_record(){
    param:dsl <<A
subcommand:
    ls          "list all records"
    put         "put record"
    del         "del record"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_dns_record_quick "$@"
        return
    fi

    ali_dns_record_"$PARAM_SUBCMD" "$@"
}

ali_dns_record_add(){
    local DomainName=${1}
    local RR=${2}
    local Value=${3}
    local Type=${4}
    if [ -z "$Type" ]; then
        if ali_is_ip "$Value"; then
            Type="A"
        else
            Type="CNAME"
        fi
    fi

    aliyun alidns AddDomainRecord \
        --DomainName "$DomainName" \
        --RR "$RR" \
        --Type "$Type" \
        --Value "$Value"
}

_ali_dns_record_ls_format(){
    ali_table_json \
        .RecordId .Status .DomainName .RR .Type .Value .Weight  # .Line .Locked
}

ali_dns_record_ls(){
#     param <<A
# options:
#     #1              "Domain Name, like x-cmd.com. Or domain name with RR keyword, like w.x-cmd.com"             =~      "[^\.]+\.[^\.]+"
# A

    if [ ! -t 1 ]; then
        _ali_dns_record_ls "$@"
    else
        _ali_dns_record_ls "$@" | _ali_dns_record_ls_format
    fi
}

_ali_dns_record_ls(){
    param:void
    case $# in
        0)  ali dns domain ls | x jq -r .[].DomainName | while read -r line; do
                _ali_dns_record_ls "$line"
            done
            ;;
        1)  local name=${1}
            local rr=${name%.*.*}
            local domain=${name#"${rr}".}
            if [ "$rr" = "$name" ]; then
                _ali_dns_record_ls1 "$name"
            else
                _ali_dns_record_ls2 "$domain" "^$rr$"
            fi
            ;;
        *)  _ali_dns_record_ls2 "$@"
            ;;
    esac    
}

ali_dns_record_cache_invalidate(){
    ccmd invalidate aliyun alidns DescribeDomainRecords --DomainName "${1:?Provide domain name}"
}

_ali_dns_record_ls1(){
    ccmd 1s -- aliyun alidns DescribeDomainRecords --DomainName "${1:?Provide domain name}" | x jq -r '.DomainRecords.Record'
}

_ali_dns_record_ls2(){
    ali_log info "_ali_dns_record_ls   ${1:?Provide domain name}   ${2:-Provide regex pattern}"
    local regex="${2}"
    _ali_dns_record_ls1 "${1}" | x jq -r "
        .[] | 
        if .RR | test(\"$regex\")           then .
        elif .Value | test(\"$regex\")      then .
        elif .RecordId | test(\"$regex\")   then .
        else empty end
    " | x jq -s .
}

ali_exactor_declare ali_dns_record \
    "No such ip found." \
    "Multiple ip found." \
    RecordId

ali_dns_record_update(){
    local RecordId=${1:?"Provide RecordId"}
    local RR=${2:?"Provide RR"}
    local Value=${3:?"Provide Work"}
    local Type=${4:?"Provide Type"}
    aliyun alidns UpdateDomainRecord \
        --RecordId "$RecordId" \
        --RR "$RR" \
        --Type "$Type" \
        --Value "$Value"
}

ali_dns_record_del(){
    param:void

    if [ "$#" -eq 1 ]; then
        case "$1" in
            *\.*)
                local name=${1}
                local rr=${name%.*.*}
                local DomainName=${name#${rr}.}
                ali_dns_record_del "$DomainName" "$rr"
                ;;
            *) 
                if aliyun alidns DeleteDomainRecord --RecordId "$1"; then
                    ali_log info "ali_dns_record_del success."
                fi
                ;;
        esac
    else
        local DomainName=${1:?"Domain Name"}
        local RR=${2:?"Provide RR"}
        local RID
        RID=$(ali_dns_record_exact_id "$DomainName" "$RR") && \
        if aliyun alidns DeleteDomainRecord --RecordId "$RID"; then
            ali_log info "ali_dns_record_del success."
        fi
    fi

    # Disable all of the cache ?
    ali_dns_record_cache_invalidate "$DomainName"
}

ali_dns_record_put(){
#     param <<A
# options:
#     #1              "Domain Name."                                                                              <DomainName>   =~ [^\.]\.[^\.]
#     #2              "Value like IP, or txt name"                                                                <Value>
#     #3              "record type, if not provided, type default is A when value is an ip, otherwise CNAME"      <Type>=A       =  A   CNAME    NS TXT  MX AAAA SRV
# A
    param:void

    local name=${1}
    # TODO
    # This is wrong. What if we own a domain like like x-cmd.com.cn ?
    # We should check the dns name. Find out which record do we match.
    local rr=${name%.*.*}
    local domain=${name#${rr}.}

    local rec=${2}
    local type=${3}
    if [ -z "$type" ]; then
        if ali_is_ip "$rec"; then
            type=A
        else
            type=CNAME
        fi
    fi

    ali_dns_record_put_raw "$domain" "$rr" "$rec" "$type"
}

ali_dns_record_put_raw(){
    local DomainName=${1:?"Domain Name"}
    local RR=${2:?"Provide RR"}
    local Value=${3:?"Provide IP"}
    local Type=${4:?"Provide Type"}

    local item
    item="$(_ali_dns_record_ls "$DomainName" "^$RR$")"
    local len
    len="$(printf "%s" "$item" | x jq '. | length' 2>/dev/null)"

    if [ "$len" -eq 0 ]; then
        ali_log info "Add New Record\n: $DomainName $RR $Value $Type"
        ali_dns_record_add "$DomainName" "$RR" "$Value" "$Type" 
    elif [ "$len" -eq 1 ]; then
        local v
        v=$(printf "%s" "$item" | x jq -r .[0].Value)
        if [ "$Value" = "$v" ]; then
            ali_log warn "Item already existed."
        else
            RID=$(printf "%s" "$item" | x jq -r .[0].RecordId)
            ali_log info "Already Register. Try to update: $RID $RR $Value $Type"
            ali_dns_record_update "$RID" "$RR" "$Value" "$Type"
        fi
    else
        ali_log error "Found More than 1 item."
        return 1
    fi && ali_dns_record_cache_invalidate "$DomainName"
}

# ali_dns_record_quick(){
#     if [ "$#" -eq 0 ]; then
#         ali_log warn "Please provide keyword"
#         return 1
#     fi

#     ali dns record ls "$@" && {
#         ps1env init "ali dns record>"
#         ps1env alias + "ali dns record ls"
#         ps1env alias :h "ali dns record help"
#         local IFS
#         local subcmd
#         while read -r subcmd; do
#             ps1env alias "+$subcmd" "ali dns record $subcmd"
#         done <<A
# $(ali dns record _param_list_subcmd)
# A
#     }
    
# }

ali_dns_record_quick(){
    ali_quicker2 dns record
}
# shellcheck shell=sh disable=SC3043

ali_easy(){
    param:dsl <<A
subcommand:
    switchip          "switch ip"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_easy_quick "$@"
        return
    fi

    "ali_easy_$PARAM_SUBCMD" "$@"
}

ali_easy_switchip(){
    :

    local ip="${1:?ip}"
    local dns=""
    if ! ali_is_ip "$ip"; then
        dns="$ip"
        ip="$(ali dns ls "$ip" | x jq -r .[0].Value 2>/dev/null)"
    fi

    if ! ali_is_ip "$ip"; then
        ali_log error "Not an ip. $ip. Receive $1"
        return 1
    fi

    local instance_id
    if ! instance_id="$(ali eip ls "$ip" | x jq -r .[0].InstanceId)"; then
        ali_log error "Cannot find instance by $ips"
        return 1
    fi

    local newip
    if ! newip="$(ali eip allocate --bandwidth 200 | x jq -r .EipAddress)"; then
        ali_log error "Cannot allocate new ip"
        return 1
    fi

    if ! ali_is_ip "$newip"; then
        ali_log error "Not an ip: $newip"
        return 1
    fi

    if ali eip unassociate "$ip" "$instance_id"; then
        ali_log info "Waiting 5s to associate to new ip"
        sleep 5s
        if ! ali eip associate "$newip" "$instance_id"; then
            ali_log error "Fail to assoicate to new ip after allocate $newip and ali eip unassociate $ip $instance_id"
            return 1
        fi

        ali eip release "$ip"
        if [ -n "$dns" ]; then
            ali dns "$dns" "$newip"
        fi
    fi

}
# shellcheck shell=sh disable=SC3043,SC2154

# author:       Li Junhao           l@x-cmd.com    edwinjhlee.github.io
# maintainer:   Li Junhao

ali_ec(){
    param:dsl <<A
subcommand:
    ls                  "list"
    quick               "quick"
    start               "start instance"
    stop                "stop instance"
    create              "create instance"
    del                 "delete instance"
    exact               "exact"
    exactid             "exactid"
    info                "info"
    
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_ec_quick "$@"
        return
    fi

    "ali_ec_$PARAM_SUBCMD" "$@"
}

ali_ec_info(){
    param:void
    ali_ec_exact "${1:?Provide keyword}"
}

# shellcheck disable=SC2120
ali_ec_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_ec_ls "$@"
        return
    fi
    
    _ali_ec_ls "$@" \
        | x jq '.[] |= . +  { 
            OSNameEn: .OSNameEn | gsub("  "; " ") | gsub("64 bit"; "")
        }' \
        | ali_table_json \
            .InstanceId .HostName .StartTime .Status .OSNameEn   CP=.Cpu    MEM=.Memory     IP=.EipAddress.IpAddress .InstanceType .StoppedMode  

}

# shellcheck disable=SC2120
_ali_ec_ls(){
    case $# in
        0)  ccmd 1s -- aliyun ecs DescribeInstances | x jq .Instances.Instance
            ;;
        *)  _ali_ec_ls | x jq .[] | _ali_ec_filter "${1:-Provide regex pattern}" | x jq -s .
            ;;
    esac
}

ali_exactor_declare ali_ec "No such ec server found." "Multiple ec server found." InstanceId

_ali_get_dns(){
    # Using dig/nslookup is much better for icmp might be disable.
    ping -W 0.01 -c 1 "${1:-hostname}" 2>/dev/null | awk 'NR==1 {
        match( $3, /\([0-9.]+\)/ )
        if (RLENGTH > 0) print substr($3, 2, RLENGTH - 2)
        else    exit 1
}'
}

ali_ec_new(){
    local s
    s=$(ali_ec_ls)    
    local len
    len=$(echo "$s" | x jq -s '. | length')
    case "$len" in
        0)  return 1        ;;
        1)  echo "$s"       ;;
        *)  echo "$s"       ;;
    esac

    return 0
}

_ali_ec_filter(){
    local pattern="${1:?Provide pattern}"
    local s
    s="$(cat)"

    local res
    res="$(x jq "
        if .EipAddress.IpAddress | test(\"${pattern}\")  then . 
        elif .InstanceId | test(\"$pattern\") then . 
        elif .HostName | test(\"$pattern\") then . 
        elif .InstanceName | test(\"$pattern\") then . 
        else empty end
    " <<A
$s
A
)"

    # Using dig for DNS
    local len
    len=$(echo "$res" | x jq -s '. | length')

    if [ "$len" != 0 ]; then
        echo "$res"
        return 0
    fi

    local ip
    if ip=$(_ali_get_dns "$pattern"); then
        x jq "
    if .EipAddress.IpAddress == \"${ip}\"  then .
    else empty end
" <<A
$s
A
        :
    fi

}

ali_ec_op(){
    param:void

    local subcmd="${1:?subcmd}"
    case "$subcmd" in
        start)          ;;
        info)           ;;
        stop)           ;;
        restart)        ;;
    esac
}

ali_ec_start(){
    param:void
    local id
    if id="$(ali_ec_exactid "$@")"; then
        ali_log info "Instance ID: $id"
        aliyun ecs StartInstance --InstanceId "$id"
    fi
}

# reboot forcely
ali_ec_reboot(){
    param:void
    local id
    if id="$(ali_ec_exactid "$@")"; then
        ali_log info "Instance ID: $id"
        aliyun ecs RebootInstance --InstanceId "$id"
    fi
}


ali_ec_stop(){
    param:void
    local id
    if id="$(ali_ec_exactid "$@")"; then
        ali_log info "Instance ID: $id"
        aliyun ecs StopInstance --InstanceId "$id"
    fi
}

ali_ec_del(){
    param:void
    local id
    if id="$(ali_ec_exactid "$@")"; then
        ali_log info "Instance ID: $id"
        aliyun ecs DeleteInstance --InstanceId "$id"
    fi
}

# aliyun ecs new-auto

# aliyun ecs new 47.242.182.73 abc
# aliyun ecs new a.lteam.top abc
# aliyun ecs host

# abc start
# abc stop
# abc info

# check hostname
# check ip
# check dns name
# check

ali_ec_disk_args(){
    printf "%s" "$1" | awk -v FS='|' '
function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function pprint(name, val){
    if (val == "") return
    printf("%s \"%s\" ", name, str_trim(val))
}

{
    pprint("--SystemDisk.Size",         $1)

    if ($2 ~ /PL[0-3]/) {
        pprint("--SystemDisk.Category",             "cloud_essd")
        pprint("--SystemDisk.PerformanceLevel",     $2)
    } else {
        if ($2 != "")   $2 = "cloud_efficiency"
        pprint("--SystemDisk.Category",     $2)
    }
    pprint("--SystemDisk.DiskName",     $3)
    pprint("--SystemDisk.Description",  $4)
}    
'
}

# ali ec create --image ubuntu_20_04_x64 --switch inner-d --type ecs.t6-c1m1.large --disk "40||brand|disk for test"
ali_ec_create(){
    param <<A
options:
    --name      "ec name"               <instance-name>=""
    --image     "Image keyword"         <image>="ubuntu_20_04_x64"
    --switch    "switch"                <switch>=""
    --type      "instance keyword"      <instance-type>
    --disk      "system disk"           <disk>="40|cloud_ssd|diskname|diskdescription"
A

    local image_id
    if ! image_id=$(ali_image_exactid "$image"); then
        return
    fi

    local switch_id
    if ! switch_id=$(ali_vpc_switch_exactid "$switch"); then
        return
    fi

    name="${name:-"$type-$(date +%y%m%d%H%m)"}"

    local disk_args
    disk_args="$(ali_ec_disk_args "$disk")"

    eval_echo aliyun ecs CreateInstance \
        --InstanceType "$type" \
        --ImageId "$image_id" \
        --VSwitchId "$switch_id" \
        "$disk_args"
}

ali_ec_quick(){
    ali_quicker2 ec
}

# shellcheck shell=sh disable=SC3043,SC2154

# elastics ip

ali_eip(){
    param:dsl <<A
subcommand:
    allocate            "handle_domains"
    release             "handling record"
    associate           "associate the ip to the instance"
    unassociate         "unassociate the ip to the instance"
    ls                  "list"
    quick               "quick"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_eip_quick "$@"
        return
    fi

    "ali_eip_$PARAM_SUBCMD" "$@"
}


ali_eip_allocate(){
    param:dsl <<A
options:
    --bandwidth|-b          "Provide bandwidth"     <bandwidth>=5
    --pay_by_bandwidth      "If set, paid by bandwdith. Otherwise, paid by traffic"
    --bgp_pro               "Only for Hongkong Region"
A
    param:run

    local args=""
    [ -n "$pay_by_bandwidth" ] && args="$args --InternetChargeType PayByBandwidth"
    [ -n "$bgp_pro" ] && args="$args --ISP BGP_PRO"

    eval aliyun ecs AllocateEipAddress --Bandwidth "${bandwidth}" "$args"
}

ali_eip_ls_format(){
    case "$LANG" in
        zh_CN*) 
            ali_table_json \
                IP地址=.IpAddress 带宽=.Bandwidth  分配时间=.AllocationTime \
                实例ID=.InstanceId 收费类型=.ChargeType 收费模式=.InternetChargeType ;;
        *)      
            ali_table_json \
                ip=.IpAddress bw=.Bandwidth charge=.ChargeType time=.AllocationTime \
                insId=.InstanceId insCharge=.InternetChargeType ;;
    esac
}

# Translate title
# Translate title

# shellcheck disable=SC2120
ali_eip_ls(){
    param:void
    case $# in
        0)  ccmd 1s -- aliyun ecs DescribeEipAddresses | x jq .EipAddresses.EipAddress
            ;;
        *)  local regex="${1:-Provide regex pattern}"
            ali_eip_ls | x jq -r "
                .[] | 
                if .IpAddress | test(\"$regex\")      then .
                elif .AllocationId | test(\"$regex\")      then .
                else empty end
            " | x jq -s .
            ;;
    esac | {
        if [ -t 1 ]; then
            ali_eip_ls_format
        else
            cat
        fi
    }
}

ali_eip_exact_id(){
    param:void
    local s
    s="$(ali_eip_ls "${1:-Provide ip}")"
    local len
    len="$(echo "$s" | x jq ' . | length ')"
    case $len in
        0)  ali_log warn "No such ip found."
            ;;
        1)  echo "$s" | x jq -r .[0].AllocationId
            return 0
            ;;
        *)  ali_log warn "Multiple ip found."
            ;;
    esac
    return 1
}

ali_eip_release(){
    param:void
    local id
    if id="$(ali_eip_exact_id "$@")"; then
        ali_log info "Allocation ID: $id"
        aliyun ecs ReleaseEipAddress --AllocationId "$id"
    fi
}

ali_eip_associate(){
    param:void
    local eip_id
    local ecs_id

    if eip_id="$(ali_eip_exact_id "${1:?Provide eip keyword}")" && \
        ecs_id="$(ali_ec_exactid "${2:?Provide ecs keyword}")"
    then
        aliyun ecs AssociateEipAddress --AllocationId "$eip_id" --InstanceId "$ecs_id"
    fi
}

# Very wired design.
# I think, only ip should be provided.
ali_eip_unassociate(){
    param:void
    local eip_id
    local ecs_id

    if eip_id="$(ali_eip_exact_id "${1:?Provide eip keyword}")" && \
        ecs_id="$(ali_ec_exactid "${2:?Provide ecs keyword}")"
    then
        aliyun ecs UnassociateEipAddress --AllocationId "$eip_id" --InstanceId "$ecs_id"
    fi
}



ali_eip_quick(){
    ali_quicker2 eip
}

# shellcheck shell=sh disable=SC3043


ali_image(){
    param:dsl <<A
subcommand:
    ls              "list"
    exact           "eaxct"
    exactid         "exactid"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_image_quick "$@"
        return
    fi

    "ali_image_$PARAM_SUBCMD" "$@"
}

# --OSType
# --PageSize

ali_image_ls_format(){
    ali_table_json .ImageId .OSName  .CreationTime # arch=.Architecture  .OSType  .Platform
}

ali_image_ls(){
#     param <<A
# subcommand:
#     linux           "Linux"
#     debian          "debian"
#     ubuntu          "ubuntu"
#     aliyun          "Aliyun"
#     centos          "CentOS"
#     win             "Windows Server 2019"
#     fedora          "Fedora"
#     suse            "suse"
#     coreos          "coreos"
# A

    local ARGS="--OSType linux"

    local platform="$1"
    ARGS=""
    # case "$PARAM_SUBCMD" in
    #     win)        ARGS="--OSType windows" ;;
    #     linux)      ARGS="--OSType linux"  ;;
    #     debian)     platform=Debian ;;
    #     ubuntu)     platform=Ubuntu ;;
    #     aliyun)     platform=Aliyun ;;
    #     centos)     platform=CentOS ;;
    #     fedora)     platform=Fedora ;;
    #     suse)       platform=SUSE ;;
    #     coreos)     platform=CoreOS ;;
    #     gentoo)     platform=Gentoo ;;
    #     *)          ARGS=""
    #                 platform="$1"
    #                 ;;
    # esac

    platform="$(printf "%s" "$platform" | tr "[:upper:]" "[:lower:]")"

    eval ccmd 3h -- aliyun ecs DescribeImages "$ARGS" --PageSize 100 | x jq .Images.Image[] | {
        if [ -z "$platform" ]; then
            cat
        else
            x jq ". | 
                if .Platform | ascii_downcase | test(\"$platform\") then . 
                elif .ImageId | ascii_downcase | test(\"$platform\") then .
                else empty end"
            # cat
        fi
    } | x jq -s . | {
        if [ -t 1 ]; then
            x jq ".[] |= . + { 
                CreationTime: .CreationTime[0:10],
                OSName: .OSName[0:30]
            }" | ali_image_ls_format
        else
            cat
        fi
    }
}

ali_exactor_declare ali_image "No such image found." "Multiple images found." ImageId

# ali_image_exact(){
#     local ret
#     ret="$(ali_image_ls "$@")"
#     local len
#     len="$(printf "%s" "$ret" | x jq '. | length')"

#     case "$len" in
#         0)  ali_log warn "No such image found.";;
#         1)  printf "%s" "$ret";;
#         *)  ali_log warn "Multiple images found.";;
#     esac
# }

# ali_image_exact_id(){
#     ali_image_exact "$@" | x jq -r .[0].ImageId
# }

# Create Image from an Instance

# 1. Take Snapshot
# 2. Save snapshot to image


# ali_image_quick(){
#     ali_quicker "ali_image" \
#         "\033[1;33mali image >\033[0m " \
#         "create|del|import" "$@"
# }


ali_image_quick(){
    ali_quicker2 image
}


# shellcheck shell=sh disable=SC3043

ali_keypair(){
    param:dsl <<A
subcommands:
    ls                  "ls"
    info                "info"
    attach              "attach"
    detach              "detach"
    import              "import"
    create              "Create"
    delete|del          "delete" 
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_keypair_quick "$@"
        return
    fi

    "ali_keypair_$PARAM_SUBCMD" "$@"
}

ali_keypair_ls_format(){
    ali_table_json \
            .KeyPairFingerPrint .KeyPairName .ResourceGroupId .CreationTime
}

ali_keypair_info(){
    param:void
    # unique in region
    local data
    if ! data="$(ali_keypair_exact "${1:-keypair name}")"; then
        return
    fi

    data="$(printf "%s" "$data" | x jq .[0])"

    echo "$data"
}

ali_keypair_ls(){
    param:void
    if [ ! -t 1 ]; then
        ccmd 1s -- _ali_keypair_ls "$@"
    else
        ccmd 1s -- _ali_keypair_ls "$@" | ali_keypair_ls_format
    fi
}

# shellcheck disable=SC2120
_ali_keypair_ls(){
    case "$#" in
        0)  aliyun ecs DescribeKeyPairs | x jq .KeyPairs.KeyPair ;;
        1)  local regex="${1:-Provide regex pattern}"
            _ali_keypair_ls | x jq "
                .[] | 
                if      .KeyPairName | test(\"$regex\")                 then .
                elif    .KeyPairFingerPrint | test(\"$regex\")          then .
                else    empty       end
            " | x jq -s .
            ;;
    esac
}

ali_exactor_declare ali_keypair \
    "No such keypair found." \
    "Multiple keypair found." \
    KeyPairName

ali_keypair_import(){
    param <<A
options:
    #1      "keypair name"
    #2      "keypair body"
A

    local name="${1:?keypair name}"
    local body="${2}"

    if [ -z "$body" ]; then
        if [ -t 0 ]; then
            local key
            printf "%s" "Import the $HOME/.ssh/id_rsa? (Enter to continue, otherwise abort): "
            ali_read key
            case "$key" in
                "") ali_log info "Using the $HOME/.ssh/id_rsa" 
                    body="$(cat "$HOME/.ssh/id_rsa.pub")"
                    ;;
                *)  ali_log warn "Abort." ;;
            esac
        else
            body="$(cat)"
        fi
    else
        if [ "$body" = "${body#ssh-rsa }" ]; then
            if [ -f "$HOME/.ssh/$body.pub" ]; then
                body="$(cat "$HOME/.ssh/$body.pub")"
            elif [ -f "$HOME/.ssh/$body" ]; then
                body="$(cat "$HOME/.ssh/$body")"
            else
                ali_log error "Not a valid key"
                return
            fi
        fi
    fi


    aliyun ecs ImportKeyPair \
        --KeyPairName "$name" \
        --PublicKeyBody "$body"

}

ali_keypair_create(){
    param <<A
options:
    #1      "keypair name"
    #2      "filepath to save private keypair"
A

    local keypairname="${1:?Keypair name}"
    aliyun ecs CreateKeyPair --KeyPairName "${keypairname}" | x jq -r .PrivateKeyBody>"${2:-"/dev/stdout"}"
}

ali_keypair_delete(){
    param <<A
options:
    #n      "keypair name list"
A

    local keypairname
    for keypairname in "$@"; do
        aliyun ecs DeleteKeyPairs --KeyPairNames "[\"${keypairname}\"]"
    done
}

ali_keypair_attach(){
    param:void
    # unique in region
    local kpid="${1:?Please provide keypair name}"
    if ! kpid="$(ali_keypair_exactid "$kpid")"; then
        ali_log warn "KP Not found"
        return 1
    fi

    local ecid="${2:?ec-id}"
    if ! ecid="$(ali_ec_exactid "${ecid}")"; then
        ali_log warn "EC Not found"
        return 1
    fi

    aliyun ecs AttachKeyPair --KeyPairName "$kpid" --InstanceIds "[\"${ecid}\"]"
}

ali_keypair_detach(){
    param:void
    # unique in region
    local kpid="${1:?Please provide keypair name}"
    if ! kpid="$(ali_keypair_exactid "$kpid")"; then
        ali_log warn "KP Not found"
        return 1
    fi

    local ecid="${2:?ec-id}"
    if ! ecid="$(ali_ec_exactid "${ecid}")"; then
        ali_log warn "EC Not found"
    fi

    aliyun ecs DetachKeyPair --KeyPairName "$kpid" --InstanceIds "[\"${ecid}\"]"

}

ali_keypair_quick(){
    ali_quicker2 keypair
}
ali_available_instance(){
    param:void
    aliyun ecs DescribeAvailableResource \
        --DestinationResource InstanceType \
            | x jq .AvailableZones.AvailableZone \
            | x jq ".[] | 
                if .ZoneId == \"$zone\" then .
                else empty  end
            " \
            | x jq '.AvailableResources.AvailableResource[0].SupportedResources.SupportedResource' \
        | {
            if [ ! -t 1 ]; then
                cat
                return
            fi

            ali_table_json .Value .Status .StatusCategory 
        }
}

# shellcheck shell=sh disable=SC3043,SC2154


# https://help.aliyun.com/document_detail/25553.html?spm=a2c4g.11186623.6.1551.67ff7b6fhY3woe

xrc ali/_v0/sg_rule

ali_sg(){
    param:dsl <<A
subcommand:
    create          "create security group"
    del             "delete security group"
    ls              "list security group"
    info            "info"
    include         "join an ec instance"
    exclude         "exclude an ec instance"
    refer           "list reference"
    rule            "sg rule managment"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_sg_quick "$@"
        return
    fi

    "ali_sg_$PARAM_SUBCMD" "$@"
}


ali_sg_create(){
    param <<A
options:
    --vpc                       "Provide vpc information"                   <vpc>
    --name                      "Default is a auto generated name"          <name>=""
    --type                      "Default is normal"                         <type>=normal               =   normal     enterprise
    --desc|--description        "Provide description"                       <description-string>=""
A

    local id
    if ! id="$(ali_vpc_exactid "$vpc")"; then
        return
    fi

    [ -n "$1" ] && name="$1"
    [ -n "$2" ] && desc="$2"

    eval aliyun ecs CreateSecurityGroup \
        --VpcId "$id" \
        ${name+--SecurityGroupName "$name"} \
        --SecurityGroupType "${type}" \
        ${name+--Description "$desc"}

}

ali_sg_ls_format(){
    ali_table_json .CreationTime .SecurityGroupId .SecurityGroupName .VpcId .SecurityGroupType
}

ali_sg_info(){
    param:void
    local data
    if ! data="$(ali_sg_exact "$@")"; then
        return
    fi

    data="$(printf "%s" "$data" | x jq .[0])"

    echo "$data"
}

# shellcheck disable=SC2120
ali_sg_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_sg_ls "$@"
    else
        _ali_sg_ls "$@" | ali_sg_ls_format
    fi
}

_ali_sg_ls(){
    case $# in
        0)  ccmd 10m -- aliyun ecs DescribeSecurityGroups | x jq .SecurityGroups.SecurityGroup
            ;;
        *)  local regex="${1:-Provide regex pattern}"
            ali_sg_ls | x jq "
                .[] | 
                if .SecurityGroupName | test(\"$regex\")      then .
                elif .SecurityGroupId | test(\"$regex\")      then .
                else empty end
            " | x jq -s .
            ;;
    esac
}


ali_exactor_declare ali_sg \
    "No such security group found." \
    "Multiple security group found." \
    SecurityGroupId


ali_sg_del(){
    param:void
    local id
    if id="$(ali_sg_exactid "$@")"; then
        ali_log info "SecurityGroup ID: $id"
        aliyun ecs DeleteSecurityGroup  --SecurityGroupId "$id"
    fi
}


ali_sg_refer(){
    param:void
    if [ ! -t 1 ]; then
        _ali_sg_refer "$@"
    else
        local s
        if s="$(_ali_sg_refer "$@")"; then
            ali_table_json .a .b <<A
$s
A
        fi
    fi
}

_ali_sg_refer(){
    local id
    if id="$(ali_sg_exactid "$@")"; then
        ali_log info "SecurityGroup ID: $id"
        aliyun ecs DescribeSecurityGroupReferences  --SecurityGroupId.1 "$id" | x jq .SecurityGroupReferences.SecurityGroupReference
        return 0
    fi
    return 1
}

ali_sg_include(){
    param:void
    local id
    if ! id="$(ali_sg_exactid "$1")"; then
        return
    fi

    shift

    local ecid
    if ! ecid="$(ali_ec_exactid "$1")"; then
        return
    fi
    aliyun ecs JoinSecurityGroup --SecurityGroupId "$id" --InstanceId "$ecid"
}

ali_sg_exclude(){
    param:void
    local id
    if ! id="$(ali_sg_exactid "$1")"; then
        return
    fi

    shift

    local ecid
    if ! ecid="$(ali_ec_exactid "$1")"; then
        return
    fi
    aliyun ecs LeaveSecurityGroup --SecurityGroupId "$id" --InstanceId "$ecid"
}

ali_sg_quick(){
    ali_quicker2 sg
}

# shellcheck shell=sh disable=SC3043

ali_sg_rule(){
    param:dsl <<A
subcommand:
    ls              "list security group rules"
    add             "add rule"
    del             "delete rules"
    ingress         "ingress"
    egress          "egress"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        if [ $# -eq 0 ]; then
            ali_sg_rule help
        else
            ali_sg_rule_quick "$@"
        fi
        return
    fi

    "ali_sg_rule_$PARAM_SUBCMD" "$@"
}


ali_sg_rule_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_sg_rule_ls "$@"
    else
        _ali_sg_rule_ls "$@" | ali_sg_rule_ls_format
    fi
}

ali_sg_rule_ls_format(){
    ali_table_json \
        .short \
        .Direction \
        .PortRange \
        DstCidr=.DestCidrIp \
        SrcPortR=.SourcePortRange \
        SrcCidr=.SourceCidrIp \
        .CreateTime \
        .Description
        # .Policy .Priority  
        # .NicType .IpProtocol
}


ALI_SG_JQ_CODE='
def fff:    if .SourceGroupId != ""                 then    [ .NicType, .IpProtocol, .PortRange, .DestCidrIp, .SourcePortRange, .SourceGroupId, .Policy, .Priority ]
            elif .SourcePrefixListId != ""          then    [ .NicType, .IpProtocol, .PortRange, .DestCidrIp, .SourcePortRange, .SourcePrefixListId, .Policy, .Priority ]
            else                                            [ .NicType, .IpProtocol, .PortRange, .DestCidrIp, .SourcePortRange, .SourceCidrIp, .Policy, .Priority ] end | join("|") ;
'

# shellcheck disable=SC2120
_ali_sg_rule_ls(){
    local id
    if ! id=$(ali_sg_exactid "${1:?Provide rule regex}"); then
        return
    fi

    case $# in
        1)  aliyun ecs DescribeSecurityGroupAttribute --SecurityGroupId "$id" | x jq "
                $ALI_SG_JQ_CODE
                .Permissions.Permission[] |= . + { short: . | fff }
            " | x jq .Permissions.Permission
            ;;
        *)  local regex="${2:-Provide regex pattern}"
            ali_sg_rule_ls "$1" | x jq "
                .[] | 
                if .Description | test(\"$regex\")      then .
                elif .Priority == $regex                then .
                else empty end
            " | x jq -s .
            ;;
    esac
}

# shellcheck disable=SC2120
_ali_sg_rule_ls_origin(){
    local id
    if ! id=$(ali_sg_exactid "${1:?Provide rule regex}"); then
        return
    fi

    case $# in
        1)  aliyun ecs DescribeSecurityGroupAttribute --SecurityGroupId "$id" | x jq '.Permissions.Permission'
            ;;
        *)  local regex="${2:-Provide regex pattern}"
            ali_sg_rule_ls "$1" | x jq "
                .[] | 
                if .Description | test(\"$regex\")      then .
                elif .Priority == $regex                then .
                else empty end
            " | x jq -s .
            ;;
    esac
}

ali_sg_rule_str(){
    x jq "
        $ALI_SG_JQ_CODE
        . | fff
    "
}


# TCP|24|0.0.0.0/0|ACCEPT|HIGH

# ali sg rule add "intranet|TCP|80-91|src-prefix-ip||0.0.0.0/0|accept|1"
# ali sg rule del "intranet|TCP|80-91|src-prefix-ip||0.0.0.0/0|accept|1"

# ali_sg_rule_parsing "intranet|TCP|80-91|src-prefix-ip||0.0.0.0/0|accept|1"
ali_sg_rule_parsing(){
    echo "${1:-Provide}" | awk -v FS='|' '
BEGIN{
    false = 0
    true = 1
}

function str_startswith(s, tgt){
    if (substr(s, 1, length(tgt)) == tgt) return true
    return false
}

function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function pprint(name, val){
    if (val == "") return
    printf("%s \"%s\" ", name, str_trim(val))
}
    
{
    $0=str_trim($0)

    if ($0 ~ /^"[^"]+"$/) {
        $0 = substr($0, 2, length($0)-2)
    }

    if (($1 != "internet") && ($1 != "intranet")) {
        
        if (str_startswith($0, "|") == true) {
            $0 = "intranet" $0
        } else {
            $0 = "intranet|" $0
        }
        # print "ffff\t" $0 "\t" $1 "\t" $2 "\t" $3 >"/dev/stderr"
    }
    pprint( "--NicType",         $1 )
    pprint( "--IpProtocol",      $2 )

    if ($3 == "") {
        if ($2 == "TCP") {
            $3 = "1/65535"
        } else {
            $3 = "-1/-1"
        }
    }
    pprint( "--PortRange",       $3 )

    pprint( "--DestCidrIp",      $4 )
    pprint( "--SourcePortRange", $5 )

    # if ($6 == "") {
    #     $6 = "0.0.0.0/0"
    # }
    pprint( "--SourceCidrIp",    $6 )
    pprint( "--Policy",          $7 )
    pprint( "--Priority",        $8 )
}
'
}

ali_sg_rule_add(){
    param:void
    ali_sg_rule_ingress_add "$@"
}

ali_sg_rule_del(){
    param:void
    ali_sg_rule_ingress_del "$@"
}

ali_sg_rule_ingress(){
    param <<A
subcommand:
    add             "add ingress rule"
    del             "delete ingress rules"
A

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_sg_rule_ingress help
        # ali_sg_ingress_quick "$@"
        return
    fi

    "ali_sg_rule_ingress_$PARAM_SUBCMD" "$@"
}

ali_sg_rule_ingress_add(){      param:void; ali_sg_rule_func AuthorizeSecurityGroup "$@";   }
ali_sg_rule_ingress_del(){      param:void; ali_sg_rule_func RevokeSecurityGroup "$@";      }

ali_sg_rule_egress(){
    param <<A
subcommand:
    add             "add ingress rule"
    del             "delete ingress rules"
A

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_sg_quick "$@"
        return
    fi

    "ali_sg_rule_egress_$PARAM_SUBCMD" "$@"
}

ali_sg_rule_egress_add(){       param:void; ali_sg_rule_func AuthorizeSecurityGroupEgress "$@";     }
ali_sg_rule_egress_del(){       param:void; ali_sg_rule_func RevokeSecurityGroupEgress "$@";        }

ali_sg_rule_egress_add_ssh(){
    :
}

ali_sg_rule_egress_add_icmp(){
    :
}

ali_sg_rule_func(){
    local func="${1:-Provide function}"
    
    local id
    if ! id=$(ali_sg_exactid "${2:?Provide rule regex}"); then
        return
    fi

    shift 2
    local rule
    local rule_args
    for rule in "$@"; do
        (
            if rule_args="$(ali_sg_rule_parsing "${rule}")"; then
                eval aliyun ecs "$func" --SecurityGroupId "$id" "$rule_args"
            fi
        ) || return  
    done
}


ali_sg_rule_quick(){
    ali_quicker2 sg rule
}

# shellcheck shell=sh disable=SC3043,SC2154

ali_ticket(){
    param:dsl <<A
subcommand:
    create          "create security group"
    del             "delete security group"
    ls              "list security group"
    info            "info"
    include         "join an ec instance"
    exclude         "exclude an ec instance"
    refer           "list reference"
    rule            "sg rule managment"
A
    param:run
    
    if [ -z "$PARAM_SUBCMD" ]; then
        ali_ticket_quick "$@"
        return
    fi

    "ali_ticket_$PARAM_SUBCMD" "$@"
}

ali_ticket_ls(){
    curl https://workorder.aliyuncs.com/?Action=ListTickets
}

# shellcheck shell=sh disable=SC3043

eval_echo(){
    echo "$@" >&2
    eval "$@"
}

ali_region(){
    param:void
    if [ -t 1 ]; then
        ccmd -- aliyun ecs DescribeRegions | x jq .Regions.Region | ali_table_json .LocalName .RegionEndpoint .RegionId
    else
        ccmd -- aliyun ecs DescribeRegions | x jq .Regions.Region
    fi
}

ali_zone(){
    param:void
    if [ -t 1 ]; then
        # aliyun ecs DescribeZones | x jq '.Zones.Zone[] | { LocalName: .LocalName, ZoneId: .ZoneId }' | x jq -s .
        ccmd -- aliyun ecs DescribeZones | x jq '.Zones.Zone[] | { LocalName: .LocalName, ZoneId: .ZoneId }' | x jq -s . | ali_table_json .LocalName .ZoneId
    else
        ccmd -- aliyun ecs DescribeZones | x jq .Zones.Zone
    fi
}


xrc ui

ali_table_json(){
    local arg
    local args
    local title
    for arg in "$@"; do
        case "$arg" in
            .*)     args="$args,$arg"      
                    title="$title ${arg#.}"      
                    ;;
            *=.*)   args="$args,${arg#*=}"
                    title="$title ${arg%%=.*}"
                    ;;
            *)      printf "%s" "Argument Wrong." >&2
        esac
    done
    args="${args#,}"

    local line
    ui table -
    IFS="
"
    eval ui table + "$title"
    for line in $(x jq -r ".[] | [ $args ] | map( . | @json) | join(\" \") "); do
        eval ui table + "$line"
    done
    ui table out 6
}

ali_instance(){
    param <<A
options:
    --mem       "Memory"        <size>=""
    --cpu       "CPU"           <core>=""
    --gpu       "GPU"           <gpu>=0
A

    {
        ccmd -- aliyun ecs DescribeInstanceTypes | x jq .InstanceTypes.InstanceType[] | x jq '
            def fun: if . == null then "" else . end;
            . |= . + { credit: .InitialCredit | fun }
        '
    } | {
        if [ -z "$mem" ]; then          cat
        else                            x jq "if .MemorySize==$mem  then .   else empty end";       fi
    } | {
        if  [ -z "$cpu" ];   then       cat
        else                            x jq "if .CpuCoreCount==$cpu  then .  else empty end";     fi
    } | {
        if  [ -z "$gpu" ];   then       cat
        else                            x jq "if .GPUAmount==$gpu     then .  else empty end";     fi
    } | x jq -s . | {
        if [ -t 1 ]; then
            ali_table_json id=.InstanceTypeId cpu=.CpuCoreCount disk=.DiskQuantity mem=.MemorySize gpu=.GPUAmount .credit
        else
            cat
        fi
    }

}


ali_exactor(){
    local code="${1:?Provide code}"
    local msg0="${2:?Provide msg0}"
    local msgn="${3:?Provide msgn}"
    shift 3

    local ret
    ret="$("$code" "$@")"
    local len
    len="$(printf "%s" "$ret" | x jq '. | length')"

    case "$len" in
        0)  ali_log warn "$msg0";;
        1)  printf "%s" "$ret"; return 0;;
        *)  ali_log warn "$msgn";;
    esac
    return 1
}

ali_exactor_declare(){
    local func="${1:?Provide funname}"
    local msg0="${2:?Provide msg0}"
    local msgn="${3:?Provide msgn}"
    local id_eval="${4:?Provide id eval}"
    eval "${func}_exact(){
        ali_exactor ${func}_ls \"$msg0\" \"$msgn\" \"\$@\"
    }
    
    ${func}_exactid(){
        local s
        if s=\$(${func}_exact \"\$@\"); then
            printf \"%s\" \"\$s\" | x jq -r '.[0].$id_eval'
        else
            return \$?
        fi
    }
    "
}

echo_eval(){
    echo "$@"
    eval "$@"
}


_ali_quicker_run(){
    # echo "$("$@")"
    eval "$@"
    # "$@"
}

ali_quicker(){
    local func="${1:?provide func}"
    local prompt="${2:?Provide prompt}"
    local reload_function="$3"
    shift 3

    local filter="$1"

    if [ ! -t 1 ]; then
        "${func}_ls" ${filter} # ${filter+"$filter"}
        return
    fi 

    local interactive_command_help
    interactive_command_help="$(cat <<A

CLICOMMANDS:
    r               reload
    q               quit
    :               : <SUBCOMMAND> [ ... <args> ]
    <cmd> [ ... <args> ]
$(${func} help)

A
)"

    local s
    s="$("${func}_ls" $filter)"
    printf "%s" "$s" | "${func}_ls_format"
    printf "%s\n" "$interactive_command_help"

    local line
    while printf "$prompt" && ali_read line; do
        eval set -- "$line"
        local cmd=$1;   shift
        case "$cmd" in
            h|help)  printf "%s\n" "$interactive_command_help" ;;
            q)  printf "\n"
                return 
                ;;
            "") continue            ;;
            r)  ;;
            :*)  
                if ! _ali_quicker_run "${func}_${cmd#:}" "$@"; then
                    continue
                fi
                ;;
            *)  
                eval "${cmd}" "$@"
                continue
        esac

        eval "
        case \"\${cmd#:}\" in
            r) ;;
            $reload_function) ;;  
            *) continue ;;
        esac
        "

        s="$(${func}_ls $filter)"   # TODO: figure out why ${filter+"${filter}"} fails
        printf "%s" "$s" | "${func}_ls_format"
    done
}

ali_quicker2(){
    param:void


    local cmd="${1:?provide cmd}"

    local IFS
    ps1env init "ali $* >"
    ps1env alias % "ali $* ls"
    ps1env alias %h "ali $* help"
    local subcmd
    while read -r subcmd; do 
        ps1env alias "%$subcmd" "ali $* $subcmd"
    done <<A
$(ali "$@" _param_list_subcmd)
A

    echo ali "$*" ls "$@"
}
# shellcheck shell=sh disable=SC3043,SC2154


xrc ali/_v0/vpc_switch

ali_vpc(){
    param:dsl <<A
subcommand:
    ls                  "list"
    create              "create"
    del                 "delete"
    modify              "start instance"
    attr                "stop instance"
    switch|sw           "Switcher management"
A
    param:run
    if [ -z "$PARAM_SUBCMD" ]; then
        ali_vpc_quick "$@"
        return
    fi

    "ali_vpc_$PARAM_SUBCMD" "$@"
}


ali_vpc_ls_format(){
    ali_table_json cidr=.CidrBlock .VpcName .Status .VpcId .VRouterId .CreationTime
}

ali_vpc_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_vpc_ls "$@"
    else
        _ali_vpc_ls "$@" | ali_vpc_ls_format
    fi
}

# shellcheck disable=SC2120
_ali_vpc_ls(){
    case "$#" in
        0)  aliyun ecs DescribeVpcs | x jq .Vpcs.Vpc ;;
        1)  local regex="${1:-Provide regex pattern}"
            _ali_vpc_ls | x jq "
                .[] | 
                if      .CidrBlock | test(\"$regex\")       then .
                elif    .VpcId | test(\"$regex\")           then .
                elif    .VpcName | test(\"$regex\")       then .
                else empty end
            " | x jq -s .
            ;;
    esac 
}

ali_exactor_declare ali_vpc \
    "No such vpc found." \
    "Multiple vpc found." \
    VpcId

ali_vpc_create(){
    param <<A
options:
    --name          "Provide name"      <name>=""
    --description   "Description"       <desc>="Create-by-x-cmd-ali-module"
    --cidr          "Subnet of 172.16.0.0/12, 10.0.0.0/8, 192.168.0.0/16"  
                                        <cidr>=""
A

    name="${name:-"xcmd-ali-v0-vpc-$(date +%y%m%d%H%m)"}"

    # 172.16.0.0/12
    # 10.0.0.0/8
    # 192.168.0.0/16
    eval aliyun ecs CreateVpc \
        ${name+--VpcName "$name"} \
        ${description+--Description "$description"} \
        ${cidr+--CidrBlock "$cidr"}
}

ali_vpc_del(){
    param:void
    local id
    if id="$(ali_vpc_exactid "$@")"; then
        ali_log info "Instance ID: $id"
        aliyun ecs DeleteVpc --VpcId "$id"
    fi
}

ali_vpc_quick(){
    ali_quicker2 vpc
}
# shellcheck shell=sh disable=SC3043

ali_vpc_switch(){
    param:dsl <<A
subcommand:
    ls                  "list"
    quick               "quick"
    del                 "delete"
    modify              "start instance"
    attr                "stop instance"
    create              "stop instance"
A
    param:run

    if [ -z "$PARAM_SUBCMD" ]; then
        ali_vpc_switch_quick "$@"
        return
    fi

    "ali_vpc_switch_$PARAM_SUBCMD" "$@"
}


ali_vpc_switch_ls_format(){
    ali_table_json cidr=.CidrBlock .VSwitchName id=.VSwitchId  .Status .VpcId .ZoneId .CreationTime .Description
}

ali_vpc_switch_ls(){
    param:void
    if [ ! -t 1 ]; then
        _ali_vpc_switch_ls "$@"
    else
        _ali_vpc_switch_ls "$@" | ali_vpc_switch_ls_format
    fi
}

_ali_vpc_switch_ls(){
    case "$#" in
        0)  if [ -n "$ALI_VPCID" ]; then
                _ali_vpc_switch_ls "$ALI_VPCID"
            fi
            aliyun ecs DescribeVSwitches | x jq .VSwitches.VSwitch ;;
        1)
            local kw="${1:?Provide keyword}"
            echo "$kw" >&2
            local vpcid
            if ! vpcid="$(ali_vpc_exactid "$kw")"; then
                aliyun ecs DescribeVSwitches | x jq .VSwitches.VSwitch | x jq "
                    .[] | 
                    if      .CidrBlock | test(\"$kw\")       then .
                    elif    .VSwitchName | test(\"$kw\")     then .
                    elif    .VSwitchId | test(\"$kw\")       then .
                    else empty end
                " | x jq -s .
            else
                aliyun ecs DescribeVSwitches --VpcId "$vpcid" | x jq .VSwitches.VSwitch
            fi
            
            ;;
        *)  
            local vpckw="${1}"
            local regex="${2}"
            _ali_vpc_switch_ls "$vpckw" | x jq "
                .[] | 
                if      .CidrBlock | test(\"$regex\")       then .
                elif    .VSwitchName | test(\"$regex\")     then .
                elif    .VSwitchId | test(\"$regex\")       then .
                else empty end
            " | x jq -s .
            ;;
    esac
}

ali_exactor_declare ali_vpc_switch "No such vpc switch found." "Multiple vpc switch found." VSwitchId

# ali vpc switch create --vpc it-switch --zone cn-hongkong-a --cidr 10.0.0.3/14 --name hi
ali_vpc_switch_create(){
    param <<A
options:
    --vpc           "vpc id or key word to search"      <id>=""
    --zone          "zone id"                           <zone-id>
    --cidr          "Subnet of 172.16.0.0/12, 10.0.0.0/8, 192.168.0.0/16"  
                                                        <cidr>
    --name          "vswitch name"                      <name>=""
    --description   "description"                       <des>=""
A

    # TODO: put it on param
    vpc="${vpc:-${ALI_VPCID}}"
    if [ -z "$vpc" ]; then
        ali_error "Please provide --vpc <vpc keywworld>"
        ali_vpc_switch_create help
        return
    fi

    local id
    if ! id="$(ali_vpc_exactid "$vpc")"; then
        return
    fi

    name="${name:-"xcmd-ali-v0-vpc-$(date +%y%m%d%H%m)"}"

    eval_echo aliyun ecs CreateVSwitch \
        ${vpc+--VpcId "$id"}    \
        ${zone+--ZoneId "$zone"} \
        ${cidr+--CidrBlock "$cidr"} \
        ${description+--Description "$description"} \
        ${name+--VSwitchName "$name"}

}

ali_vpc_switch_del(){
    param:void
    local id
    id="$(ali_vpc_switch_exactid "$1")"
    eval aliyun ecs DeleteVSwitch --VSwitchId "$id"
}

ali_vpc_switch_modify(){
    :
}

ali_vpc_switch_quick(){
    param:void
    local ALI_VPCID="$1"

    local prompt

    if [ -n "$ALI_VPCID" ]; then
        local vpcid
        if ! vpcid="$(ali_vpc_exactid "${ALI_VPCID}")"; then
            return
        fi
        ALI_VPCID="$vpcid"
        prompt="\033[1;31mCurrent VPC ID: $vpcid
"
    fi

    prompt="
$prompt\033[1;33mali vpc switch >\033[0m "

    ali_quicker "ali_vpc_switch" \
        "${prompt}"\
        "create|del" "$@"
}
