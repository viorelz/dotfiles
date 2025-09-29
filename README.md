# devops-tools

## Prerequisites

Please install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install#change-the-default-linux-distribution-installed)

To ensure you have internet connectivity in your WSL terminal while your VPN is on, **please run a PowerShell as Administrator** and run the following command AFTER you turned your VPN on:
```
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Set-NetIPInterface -InterfaceMetric 6000
```

Endava users might also want to add these lines in their etc/hosts to make Gitlab and Jira accessible after running the above Get-Adapter command:
```
10.225.101.238 jira.sportradar.ag
10.72.50.59    gitlab.sportradar.ag
```
Please ask a DevOps if you still have connectivity issues.

## Quick and easy

Please clone this repo inside your WSL home folder. You could then copy .bashrc to your $HOME folder

install the devpos tools and source the new ~/.bashrc file by running:

```
./devops-tools_install.sh
```
Ask Vio, Jovan or PK for K8s connection certificates.

## The longer road
### NOT for the fainthearted, because it does NOT work without review and adaptation!

You could overwrite all .bash* files by running:
```
./install.sh
```
Or you could adapt the Makefile to your needs and have symlinks to all config files so you can keep up with the latest changes in the repo.

## Homebrew bundle (macOS)
If you're on macOS and want to install the curated toolset, review and then run:
```
brew bundle --file=./Brewfile
```
You can see what would be installed without changing anything:
```
brew bundle check --file=./Brewfile
```
Regenerate the Brewfile from your current system (review the diff before committing):
```
brew bundle dump --file=./Brewfile --force
```

## Function & alias help
Most helper functions are documented inline in `.bash_functions` (open it or `grep '^##' .bash_functions`). Aliases live in `.bash_aliases`. After sourcing your new environment you can inspect definitions with:
```
type functionName
```
Example:
```
type mkcd
```

## AWSCli & K8s config
Among the devops tools you also get the awscli. To use it, please browse to AWS, click the "Command line or programmatic access" link of the desired AWS account:
![AWS Start](/docs/aws_start.jpg "AWS Start")

then click your favorite credentials block to copy/use the AWS creds:
![AWS Credentials](/docs/aws_creds.jpg "AWS Credentials")

This repo also contains a kube_config file that you can copy in/as $HOME/.kube/config and then fill in the certificate (please contact your favorite DevOps to get the certificate).

```
mkdir -p ~/.kube
cp kube_config ~/kube/config
```

You can always have a look at the available aliases by running `less ~/.bash_aliases`.

The K8s Cheat Sheet can be found [here](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).
Some if the most used commands are:

```
k auth can-i --list
k --debug apply -f tcpingress.yml -n namespaceName
k --help

kdebug 
kdebug_busy 
kdebug_ubuntu 


k -n conexp rollout restart deployment/bff-downstream-mock-service
k -n conexp rollout restart deployment/contract-service
k -n flux get pods
k -n flux get pods -w
k apply -f efs-sc.yaml
k attach -n flux flux-helm-operator-5bcf5bfdf8-7tg8x -i
k attach ecsdemo-frontend-697b949bb4-cp72d -i
k cluster-info
k cluster-info dump
k config current-context
k config get-contexts
k delete --help
k delete -f efs-sc.yaml 
k delete deployment kong
k delete hpa contract-service
k delete ingress contract-service
k delete namespace kong
k delete persistentvolume kafka-storage
k delete persistentvolumeclaim kafka-data
k delete pod --help
k delete pod -n namespaceName pg-bouncer-559d699dcd-hxsbm
k delete pod datadog-p6h74 -n monitoring
k delete secret -n cert-manager sh.helm.release.v1.cert-manager.v2
k edit HorizontalPodAutoscaler ctp-adf-bridge
k edit deployment bedchecker-backend
k edit helm release ctp-adf-bridge
k edit ing ctp-adf-bridge
k edit kongplugin ctp-oneapp-cors 
k edit storageclass efs-sc
k edit svc device-fulfillment-engine
k edit svc/pg-bouncer
k event
k events
k exec --stdin --tty -n flux flux-helm-operator-5bcf5bfdf8-7tg8x -- /bin/sh
k exec --stdin --tty ecsdemo-frontend-697b949bb4-cp72d -- /bin/bash
k exec --stdin --tty ecsdemo-frontend-697b949bb4-cp72d -c ecsdemo-efs-test -- /bin/bash
k exec --stdin --tty ecsdemo-frontend-697b949bb4-cp72d -c ecsdemo-efs-test -- /bin/sh
k exec -it pods/kong-data-plane-kong-56d948d68c-gll6t ingress-controller /bin/sh
k explain ingress.spec
k explain ingress.spec.rules
k explain ingress.spec.tls
k explain pods
k explain pods.spec.containers
k g cm --all-namespaces
k restart --help
k restart pod pt-connected-mileage-9745bd478-75bfj
k scale deployment pt-connected-mileage --replicas 1
k scale deployment pt-connected-mileage --replicas 2
k top node
k top pod
kbpa
kd -n external-dns external-dns-7dc584799d-wxjbh
kd ClusterIssuer letsencrypt-prod
kd clusterissuers letsencrypt-prod
kd clusterissuers letsencrypt-prod | less
kd clusterrole users
kd crd kongingresses.configuration.konghq.com | less
kd deployment -n conexp contract-service
kd deployment strongdm/device-masters-dev-sdm-relay-2
kd helmrelease eksdemo
kd helmreleases -n flux
kd helmreleases -n flux flux-helm-operator
kd hpa
kd ing
kd ingress -n namespaceName pg-bouncer
kd job kafka-secrets-to-ecs
kd node ip-10-24-2-81.eu-central-1.compute.internal
kd persistentvolume kafka-storage
kd persistentvolumeclaim kafka-data
kd pod -n monitoring datadog-cluster-agent-65c87d45f4-khbjq | less
kd pod -n myPod-dev pg-bouncer-5dc7ff5b57-24jk6
kd pv pvc-8bd4b333-70f1-4492-8d2b-5a61df0c6d62
kd pvc kubecost-cost-analyzer
kd role consul-server
kd rs -n kong | less
kd sa default 
kd service -n namespaceName pg-bouncer
kd serviceaccount external-dns -n external-dns
kd storageclass efs-kafka-certs
kd storageclass efs-sc
kd strongdm/device-masters
kd svc
kd svc cert-manager -n cert-manager
kd svc/kong-data-plane-kong-proxy
kd tcpingress pg-bouncer
kdd kong | less
kddn kinto-pt pt-connected-mileage
kdebug 
kdebug_busy 
kdebug_ubuntu 
kdpn kong kong-data-plane-kong-699fc94fc-gjfq9
kds pg-bouncer-userlist
kdsn gazoo-pg-bouncer gazoo-pg-bouncer-pg-bouncer
kdsv
kdsvn cert-manager cert-manager
kdsvn pg-bouncer
kg --help
kg -n namespaceName svc
kg ClusterIssuer -A
kg ClusterIssuer letsencrypt-prod
kg HorizontalPodAutoscaler
kg HorizontalPodAutoscaler eu-dealer-service -o yaml
kg KongClusterPlugin -A
kg KongPlugin -A
kg KongPlugin fsl-redirect -o yaml
kg TCPIngress -A
kg all
kg all --all-namespaces -l='app.kubernetes.io/managed-by=Helm'
kg all -A
kg all -n namespaceName
kg certificate
kg certificate -A
kg certificate -n namespaceName
kg certificates.cert-manager.io -A
kg clusterissuer
kg clusterissuers -A
kg clusterissuers letsencrypt-prod
kg clusterissuers.cert-manager.io
kg clusterissuers.cert-manager.io -A
kg clusterrole users -o yaml
kg clusterroles -A
kg cm --all-namespaces
kg cm -n monitoring datadog-cluster-id
kg cm -n monitoring datadog-cluster-id -o yaml | less
kg configmap
kg configmap -A
kg configmap msk-conf -o yaml
kg crd
kg crd -A
kg crd -n kong
kg crd kongingress
kg crd kongingresses
kg crd kongingresses -n kong
kg crd kongingresses.configuration.konghq.com
kg crd tcpingresses.configuration.konghq.com
kg crds
kg cronjob -A
kg deployment
kg deployment efs-csi-controller -o yaml | less
kg deployments -A
kg events
kg events --all-namespaces -w
kg events -A
kg events -A -o wide | less
kg events -n collision collision-7f875875fc-6nv6d
kg events -n kong
kg events -n kube-system
kg events -n namespaceName
kg events -n namespaceName -w
kg events pg-bouncer-7dd59fc77d-xqz4l -n namespaceName
kg helm releases -A
kg helmrelease -n kong
kg helmrelease ctp-adf-bridge -o yaml
kg helmrelease deploy-kafka-integration -o yaml > ../deploy-kafka-integration.now
kg helmrelease deploy-kafka-integration -o yaml | grep proxy-ssl-redirect
kg helmreleases -A
kg hr -n myPod-dev
kg ing -A
kg ing -n kong
kg ingress
kg ingress -A
kg ingress -n conexp
kg ingress -n namespaceName
kg kongplugins -A
kg kongplugins -n kong
kg kongplugins.configuration.konghq.com -A
kg kongplugins.configuration.konghq.com -n kong
kg namespaces
kg node ip-10-34-42-111.eu-central-1.compute.internal -o yaml | grep zone
kg nodes
kg nodes --output wide
kg nodes --show-labels
kg nodes --show-labels | grep -Eo 'beta.*'
kg nodes -A
kg nodes -A -o wide
kg p,svc,deployments
kg pods
kg pods -A
kg pods -n flux
kg rs
kg rs -A
kg rs -n kong
kg secrets
kg secrets -A
kg secrets -A > tmp.secretlist
kg secrets -A | grep flux
kg secrets -A | less
kg secrets -n ecare gitlab-devops-docker-image-pull-secrets -o json
kg serviceaccount external-dns -n external-dns -o yaml
kg serviceaccounts -A
kg svc
kg svc -A
kg svc -n cert-manager
kg tcpIngress -A
kg tcpingress
kg tcpingress -A
kg tcpingress -n namespaceName
kl --help
kl --namespace flux flux-helm-operator-5bcf5bfdf8-455d8
kl --namespace flux flux-helm-operator-5bcf5bfdf8-455d8 | less
kl -l 'app.kubernetes.io/name=kong' --all-containers
kl -n cert-manager cert-manager
kl -n cert-manager cert-manager-7c8c8965fd-vk2z9
kl -n cert-manager cert-manager-7c8c8965fd-vk2z9 | less
kl -n cluster-autoscaler cluster-autoscaler-79578b9887-b9rgw -f
kl kong-data-plane-kong-547d865d6f-r8rh5
kl pod/collision-6dc8b9b474-dw22m
kl pods/kong-data-plane-kong-58d658b4f-2ghbh proxy -n kong
```