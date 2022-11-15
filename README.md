# Glovo &amp; Friends 2022: Event Based Autoscaling demo
In this repository you will find all the necessary steps to test the Event Based Autoscaling demo

## Requirements

* [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) to create a testing cluster 
* SQS Queue and IAM user from your AWS account
* [Helm](https://helm.sh/docs/intro/install/) 
* [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Steps
1. Make sure to have all the requirements installed and ready before proceeding
2. Clone this repository and set your current directory to the root of it
3. Initialise the environment by running `make init`
4. Substitute the following variables in the repo
   1. <QUEUE_URL> for you AWS SQS queue URL
   2. <AWS_ACCESS_KEY_ID> for your AWS_ACCESS_KEY_ID with permissions to read the SQS queue in base64
   3. <AWS_SECRET_ACCESS_KEY> for your AWS_SECRET_ACCESS_KEY with permissions to read the SQS queue in base64
   4. <AWS_REGION> for the AWS_REGION where your queue is located
5. Run `make deploy`
6. Setup your AWS credentials with a user/role with write access to your AWS SQS queue. It can be the same credentials used for keda, but not necessarily
7. Observe how the different resources have been created (ScaledObject, TriggerAuthentication, HPA, Deployment)
8. Generate some messages with `make load`