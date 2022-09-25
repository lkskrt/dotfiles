function aws_get_alb_priorities -a name port -d 'List all priorities of an AWS ALB listener'
    set lbArn (aws elbv2 describe-load-balancers --names "$name" --query 'LoadBalancers[].[LoadBalancerArn]' --output text)
    echo "ALB ARN is: $lbArn"

    set listenerArn (aws elbv2 describe-listeners --load-balancer-arn $lbArn --query 'Listeners[].{ListenerArn:ListenerArn,Protocol:Protocol,Port:Port}' | jq -r ".[] | select(.Port=="$port").ListenerArn")
    echo "Listener ARN is: $listenerArn"

    echo "Rules are:"
    # aws elbv2 describe-rules --listener-arn $listenerArn --query 'Rules[].{Priority:Priority,Host:Conditions[0].Values[0]}' | jq
    aws elbv2 describe-rules --listener-arn $listenerArn | jq
end
