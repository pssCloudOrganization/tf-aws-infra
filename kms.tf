
resource "aws_kms_key" "ec2_key" {
  description              = "CSYE6225 KMS Key for EC2"
  deletion_window_in_days  = 10
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
  tags = {
    Name = "csye6225-ec2 key"
  }

  policy = <<EOF
{
    "Id": "key-for-ec2",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow autoscaling role access",
            "Effect": "Allow",
            "Principal": {
               "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow aws-cli-demo update key description",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/aws-cli-demo"
            },
            "Action": [
                "kms:UpdateKeyDescription"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_kms_key" "rds_key" {
  description             = "KMS Key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ec2-key"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:*"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/aws-cli-demo"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/aws-cli-demo"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "rds-encryption-key"
  }
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS Key for S3 encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode(
    {
      "Id" : "key-for-rds",
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },

        {
          "Sid" : "Allows access for Key Administrators",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EC2-S3-Access-Role"
          },
          "Action" : [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ],
          "Resource" : "*"
        }
        ,
        {
          "Sid" : "Allows use of the key",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EC2-S3-Access-Role"
          },
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "Allows attachment of Persistent Resources",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EC2-S3-Access-Role"
          },
          "Action" : [
            "kms:RevokeGrant",
            "kms:CreateGrant",
            "kms:ListGrants"
          ],
          "Resource" : "*",
          "Condition" : {
            "Bool" : {
              "kms:GrantIsForAWSResource" : "true"
            }
          }
        }
      ]
    }

  )

  tags = {
    Name = "s3-encryption-key"
  }
}


resource "aws_kms_key" "secrets_key" {
  description             = "KMS Key for Secrets Manager"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode(

    {
      "Id" : "key-for-secrets-manager",
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "UseKeyForSpecificSecret",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "secretsmanager.amazonaws.com"
          },
          "Action" : [
            "kms:Decrypt",
            "kms:Encrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}",
              "kms:ViaService" : "secretsmanager.us-east-1.amazonaws.com"
            }
          }
        },
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },
        {
          "Sid" : "Allow access for Key Administrators",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/aws-cli-demo"
          },
          "Action" : [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion",
            "kms:RotateKeyOnDemand"
          ],
          "Resource" : "*"
        }

      ]
    }

  )

  tags = {
    Name = "secrets-manager-key"
  }
}

resource "aws_kms_alias" "ec2_alias" {
  name          = "alias/ec2-key"
  target_key_id = aws_kms_key.ec2_key.id
}

resource "aws_kms_alias" "rds_alias" {
  name          = "alias/rds-key"
  target_key_id = aws_kms_key.rds_key.id
}

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3_key.id
}

resource "aws_kms_alias" "secrets_alias" {
  name          = "alias/secrets-key"
  target_key_id = aws_kms_key.secrets_key.id
}

