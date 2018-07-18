

# Variables
# --------------------------------------

variable "trustor" {
  description = "The name of the role to create in the trusting account"
}

variable "policy_arns" {
  type = "list"
  description = "A list of policy arns to attach to the trusting account role, providing access to the trustee"
}

variable "trustee" {
  description = "The ARN of the user in the trusted account to give access to the trusting account"
}

variable "trustee_policy_name" {
  description = "The name of the policy to create in the trustee account"
}



# Providers
# --------------------------------------
provider "aws" {
  alias = "trustor"
}

provider "aws" {
  alias = "trustee"
}



# Policy Documents
--------------------------------------
data "aws_iam_policy_document" "trustor_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    pricipals {
      type        = "AWS"
      identifiers = ["${var.trustee}"]
    }
  }
}

data "aws_iam_policy_document" "trustee_role" {

  statement {
    effect   = "Allow"
    actions  = ["sts:AssumeRole"]
    resource = ["${aws_iam_role.trustor_role.arn}"]
  
    principals {
      type = "AWS"
      identifiers = ["${var.trustee}"]
    }
  }
}


# Resources
# --------------------------------------

resource "aws_iam_role" "trustor_role" {
  provider = "trustor"

  name               = "${var.trustor}"
  assume_role_policy = "${data.aws_iam_policy_document.trustor_role.json"
}

resource "aws_iam_role_policy_attachment" "trustor_role" {
  count    = "${length(var.policy_arns)}"
  providor = "trustor"

  role       = "${aws_iam_role.trustor_role.name}"
  policy_arn = "${element(var.policy_arns, count.index)}"
}

resource "aws_iam_policy" "trustee_policy" {
  provider = "trustee"

  name        = "${var.trustee_policy_name}"
  path        = "/"
  description = "Allow ${var.trustee} to assume ${var.trustor}"
  policy      = "${data.aws_iam_policy_document.trustee_role.json}"
}

resource "aws_iam_policy_attachement" "trustee_role" {
  provider = "trustee"

  role       = "${var.trustee}"
  policy_arn = "${aws_iam_policy.trustee_policy.arn}"
}


# Outputs
# --------------------------------------
output "trustor" { value = "${aws_iam_role.trustor_role}" }
