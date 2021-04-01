declare -a NAMESPACES=("balancereader" "transactionhistory" "ledgerwriter" "contacts" "userservice" "frontend" "loadgenerator")

for ns in "${NAMESPACES[@]}"
do
    kubectl delete -n $ns deployments,jobs,services --all
done 