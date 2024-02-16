
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

function red() {
    echo -e "$RED$*$NORMAL"
}

function green() {
    echo -e "$GREEN$*$NORMAL"
}

function yellow() {
    echo -e "$YELLOW$*$NORMAL"
}

function mkcd()
{
    if [ $# -eq 0 ]; then
        echo "Usage: mkcd dirName"
    else
        mkdir $1
        cd $1
    fi
}

# Base64 encode 
function base64-encode() {
   echo -n "$@" | base64;
}

# Base64 decode 
function base64-decode() {
    echo -n "$@" | base64 -d;
}

# cd and ls
function cl() {
    DIR="$*";
        # if no DIR given, go home
        if [ $# -lt 1 ]; then
                DIR=$HOME;
    fi;
    builtin cd "${DIR}" && \
    # use your preferred ls command
        ls -F --color=auto
}

# extracts the given file
x () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# Run `dig` and display the most useful info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
    if [ -z "${1}" ]; then
        echo "ERROR: No domain specified.";
        return 1;
    fi;

    local domain="${1}";
    echo "Testing ${domain}…";
    echo ""; # newline

    local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
        | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

    if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText=$(echo "${tmp}" \
            | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
            no_serial, no_sigdump, no_signame, no_validity, no_version");
        echo "Common Name:";
        echo ""; # newline
        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
        echo ""; # newline
        echo "Subject Alternative Name(s):";
        echo ""; # newline
        echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
            | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
        return 0;
    else
        echo "ERROR: Certificate not found.";
        return 1;
    fi;
}

# ----------------------
# Git Functions
# ----------------------
# Git log find by commit message
function glf() { git log --all --grep="$1"; }

# descend into subdirectories and do git status
gssubdirs () {
  find ./ -mindepth 1 -maxdepth 1 -type d | while read dir
  do
    cd ${dir}
    yellow $dir
    git status
    cd ..
  done
}

# descend into subdirectories and do git pull
gpsubdirs () {
  find ./ -mindepth 1 -maxdepth 1 -type d | while read dir
  do
    cd ${dir}
    git status | head -n1 | grep master >/dev/null 2>&1
    # check if exit status of above was 0, indicating we're in a git repo
    if [ ! $? -eq 0 ];
    then
      echo "${dir%*/} is NOT on master..."
    fi
    git pull origin master
    cd ..
  done
}

# find git ignored files and display the decisive rule
gfignored () {
    find ./ -not -path './.git/*' -not -path '*/.terraform*' | git check-ignore -v --stdin
}


#TerraForm MOdule Initialize
function tfmoi {
  if [ $# -eq 0 ]; then
      echo "Usage: tfmoi moduleNameDir"
  else
    mkdir -p $1
    touch $1/locals.tf
    touch $1/main.tf
    touch $1/outputs.tf
    touch $1/providers.tf
    touch $1/variables.tf
    touch $1/versions.tf
  fi
}

# TerraForm MOdule Explained
function tfmoe {
  if [ $# -eq 0 ]; then
      echo "Usage: tfmoe moduleNameDir"
  else
    echo -e "\nOutputs:"
    grep -r "output \".*\"" $1 |awk '{print "\t",$2}' |tr -d '"'
    echo -e "\nVariables:"
    grep -r "variable \".*\"" $1 |awk '{print "\t",$2}' |tr -d '"'
  fi
}


##################
### AWS SSO Access
function awa () {
    # AWS account login function using a SSO profile.
    # Requirements:
    #    - aws cli installed
    #    - aws SSO config created with profiles described in acmap

    declare -A acmap
    C=1
    aws_profiles=$(cat ~/.aws/config | grep "\[profile " | sed -e 's/\[//g' -e 's/\]//g' -e 's/profile //g' | tr -d \''"\\')

    for awp in $aws_profiles
    do 
      acmap["$awp"]="$awp"
    done

    for key in $(echo ${!acmap[@]} | tr ' ' $'\n' | sort ); do
        echo "$C: $key"
        aclist[$C]="${acmap[$key]}"
        C=$((C + 1))
    done

    read -p 'Choose an AWS account: ' REPLY
    if ((REPLY >= 1 && REPLY <= C-1)); then
        echo "Using AWS profile: ${aclist[$REPLY]}"
        export AWS_PROFILE="${aclist[$REPLY]}"
        aws sso login
    else
        echo "Invalid response, try again"
    fi

    echo ""
}

function awp () {
    # AWS profile switch function when SSO login already happened.
    # Requirements:
    #   - aws cli installed
    #   - aws SSO config created with profiles described in acmap

    declare -A prmap
    C=1
    aws_profiles=$(cat ~/.aws/config | grep "\[profile " | sed -e 's/\[//g' -e 's/\]//g' -e 's/profile //g' | tr -d \''"\\')

    for awp in $aws_profiles
    do 
      prmap["$awp"]="$awp"
    done
    
    for key in $(echo ${!prmap[@]} | tr ' ' $'\n' | sort ); do
        echo "$C: $key"
        prlist[$C]="${prmap[$key]}"
        C=$((C + 1))
    done

    read -p 'Choose an AWS profile: ' REPLY
    if ((REPLY >= 1 && REPLY <= C-1)); then
        echo "Using AWS profile: ${prlist[$REPLY]}"
        export AWS_PROFILE="${prlist[$REPLY]}"
    else
        echo "Invalid response, try again"
    fi

    echo ""
}

function awr () {
    # AWS region switch function
    # Requirements:
    #   - aws profile must be set into environment variable

    if [ $# -eq 1 ] && [[ $1 == "default" ]]; then
        aws_region="$(aws configure get region)"
		export AWS_REGION="${aws_region}"
    	echo "Listing available AWS EKS clusters. To connect to a specific cluster just type awc <cluster_name>"
	    aws eks list-clusters
	    echo ""
        return
	fi

    declare -A remap
    C=1
    regions=$(aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1)
    default_aws_region="$(aws configure get region)"

    for awr in $regions
    do
      remap["$awr"]="$awr"
    done

    for key in $(echo ${!remap[@]} | tr ' ' $'\n' | sort ); do
        echo "$C: $key"
        relist[$C]="${remap[$key]}"
        C=$((C + 1))
    done

    read -p 'Choose an AWS Region ('$default_aws_region'): ' REPLY
    if ((REPLY >= 1 && REPLY <= C-1)); then
        echo "Using AWS region: $({relist[$REPLY]})"
        aws_region="${relist[$REPLY]}"
    else
        echo "Using AWS region: $(aws configure get region)"
        aws_region="${default_aws_region}"
    fi

    export AWS_REGION="${aws_region}"
    echo "Listing available AWS EKS clusters. To connect to a specific cluster just type awc <cluster_name>"
    aws eks list-clusters
    echo ""
}

function awc () {
    # AWS eks cluster switch function
    # Requirements:
    #    - cluster name must be specified (awc "cluster_name")
    #    - aws profile must be set into environment variable
    #    - aws region must be set into environment variable

    declare -A rlmap
    C=1
    rlmap["AdministratorAccess"]="AdministratorAccess"
    rlmap["PowerUserAccess"]="PowerUserAccess"
    rlmap["ReadOnlyAccess"]="ReadOnlyAccess"

    if [ $# -eq 0 ]
        then
        echo "Listing available AWS EKS clusters. To connect to a specific cluster just type awc <cluster_name>"
        /usr/local/bin/aws eks list-clusters
    else
        echo "Connecting to AWS EKS cluster \"$1\""
        aws_account_id=$(aws configure get sso_account_id)
        default_aws_role="AdministratorAccess"
        C=1

        for key in $(echo ${!rlmap[@]} | tr ' ' $'\n' | sort ); do
          echo "$C: $key"
          rllist[$C]="${rlmap[$key]}"
          C=$((C + 1))
        done

        read -p 'Choose an AWS IAM access role ('$default_aws_role'): ' REPLY
        if ((REPLY >= 1 && REPLY <= C-1)); then
          aws_role="${rllist[$REPLY]}"
        else
          aws_role="${default_aws_role}"
        fi

        CMD=$(/usr/local/bin/aws eks update-kubeconfig --name $1 --role-arn arn:aws:iam::$aws_account_id:role/$aws_role)
        eval echo \"'$CMD'\"

        unset AWS_PROFILE
        unset AWS_REGION
    fi

    echo ""
}

function sopson() {
    unset AWS_SESSION_TOKEN
    assumed_role=$(aws sts assume-role \
        --role-arn arn:aws:iam::XXXXXXXXXXX:role/RootOrganizationAccountAccessRole \
        --role-session-name assume-account --profile tceu-tlz-root-prod)
    export AWS_ACCESS_KEY_ID=$(echo $assumed_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $assumed_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $assumed_role | jq -r .Credentials.SessionToken)
}

function sopsoff() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
}

kdebug_busy() {
    kubectl run -i --rm --tty debug --image=busybox --restart=Never -- sh
}

kdebug_ubuntu() {
    kubectl run -i --rm --tty debug --image=ubuntu --restart=Never -- sh
}

function get_secret {
    command="vault kv get -field=$1 $2";
    echo >&2 $command;
    eval $command;
}

