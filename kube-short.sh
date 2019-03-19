# kubectl 简命令

kb(){
kubectl $@;
}

# kba 所有namespace
kall(){ kubectl $@ --all-namespaces; }

#ks 系统命名空间
ksys() { kubectl $@ -n kube-system; }

# 所有空间的
# get

kgeta() { kall get $@ ;}

# apply
kappa() { kall apply $@ ;}

# describe 
kdesa() { kall describe $@ ;}

#delete
kdela() { kall delete $@ ;}

#edit
kedia() { kall edit $@ ;}

# 默认空间�?##############################################
namespace="default"
s="kube-client.$namespace() { kubectl \$@ -n $namespace; }"
eval $s
# get

kget() { kube-client.default get $@ ;}

# apply
kapp() { kube-client.default apply $@ ;}

# describe 
kdes() { kube-client.default describe $@ ;}

#delete
kdel() { kube-client.default delete $@ ;}

#edit
kedi() { kube-client.default edit $@ ;}
###############################################

# kube-system 命名空间

##############################################
namespace="kube-system"
s="kube-client.$namespace() { kubectl \$@ -n $namespace; }"
eval $s
# get

kgets() { kube-client.kube-system get $@ ;}

# apply
kapps() { kube-client.kube-system apply $@ ;}

# describe 
kdess() { kube-client.kube-system describe $@ ;}

#delete
kdels() { kube-client.kube-system delete $@ ;}

#edit
kedis() { kube-client.kube-system edit $@ ;}
###############################################


