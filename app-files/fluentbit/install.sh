#!/bin/bash

kubectl create serviceaccount fluent-bit-sa -n amazon-cloudwatch
kubectl annotate serviceaccount fluent-bit-sa -n amazon-cloudwatch eks.amazonaws.com/role-arn=arn:aws:iam::571480186401:role/gj2025-fluent-bit-role