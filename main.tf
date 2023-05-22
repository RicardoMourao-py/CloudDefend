############################### Provider #####################################

# Provide AWS Credentials
provider "aws" {
  region = "us-east-1"
}

############################## Politicas ###################################

# Cria função da integração com a política necessária
resource "aws_iam_role" "s3_api_gateyway_role" {
  name = "s3-api-gateyway-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
  EOF
}

# Anexar política de acesso S3 à função de gateway de API
resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = "${aws_iam_role.s3_api_gateyway_role.name}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"  
}

# Create S3 Full Access Policy
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy"
  description = "Policy for allowing all S3 Actions"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

# Cria a política do bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

# cria um IAM para ser referenciado na política do bucket
data "aws_iam_policy_document" "allow_access_from_another_account" {
  version = "2012-10-17"
  
  statement {
    sid     = "APIProxyBucketPolicy"
    actions = ["s3:GetObject"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    resources = ["arn:aws:s3:::check-request-2/*"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:execute-api:us-east-1:108791993403:${aws_api_gateway_rest_api.MyS3.id}/*/GET/"]
    }
  }
}

##############################  S3 #########################################

resource "aws_s3_bucket" "site_bucket" {
  bucket = "check-request-2"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.site_bucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.site_bucket.id
  key    = "error.html"
  source = "error.html"
  content_type = "text/html"
}


resource "aws_s3_bucket_website_configuration" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "meu_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##########################  API Gateway ####################################

# Cria API REST
resource "aws_api_gateway_rest_api" "MyS3" {
  name        = "MyS3"
  description = "API for S3 Integration"
}

# Cria o método na raiz
resource "aws_api_gateway_method" "GetBuckets1" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id   = "${aws_api_gateway_rest_api.MyS3.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

# Etapa para a integração do S3 no GET raiz
resource "aws_api_gateway_integration" "S3Integration1" {
  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id = "${aws_api_gateway_rest_api.MyS3.root_resource_id}"
  http_method = "${aws_api_gateway_method.GetBuckets1.http_method}"

  integration_http_method = "GET"

  type = "AWS"
  uri         = "arn:aws:apigateway:us-east-1:s3:path/check-request-2/index.html"
  
  credentials = "${aws_iam_role.s3_api_gateyway_role.arn}"

}

# Criando recurso
resource "aws_api_gateway_resource" "Object" {
  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  parent_id   = "${aws_api_gateway_rest_api.MyS3.root_resource_id}"
  path_part   = "{object}"
}

# Cria o método no recurso
resource "aws_api_gateway_method" "GetBuckets2" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id   = "${aws_api_gateway_resource.Object.id}"
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.object" = true
  }
}

# Etapa para a integração do S3 no GET do object
resource "aws_api_gateway_integration" "S3Integration2" {
  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id = "${aws_api_gateway_resource.Object.id}"
  http_method = "${aws_api_gateway_method.GetBuckets2.http_method}"

  integration_http_method = "GET"

  type = "AWS"
  uri         = "arn:aws:apigateway:us-east-1:s3:path/check-request-2/{object}"
  
  credentials = "${aws_iam_role.s3_api_gateyway_role.arn}"

  request_parameters = {
      "integration.request.path.object" = "method.request.path.object"
    }
}

resource "aws_api_gateway_integration_response" "MyS3IntegrationResponse" {
  depends_on = [aws_api_gateway_integration.S3Integration1]

  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id = "${aws_api_gateway_rest_api.MyS3.root_resource_id}"
  http_method = "${aws_api_gateway_method.GetBuckets1.http_method}"
  status_code       = "200"  

  response_parameters = {
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }

}

resource "aws_api_gateway_integration_response" "MyS3IntegrationResponse_object" {
  depends_on = [aws_api_gateway_integration.S3Integration2]

  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  resource_id = "${aws_api_gateway_resource.Object.id}"
  http_method = "${aws_api_gateway_method.GetBuckets2.http_method}"
  status_code       = "200"  

  response_parameters = {
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_rest_api.MyS3.root_resource_id
  http_method = aws_api_gateway_method.GetBuckets1.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_method_response" "response_200_object" {
  rest_api_id = aws_api_gateway_rest_api.MyS3.id
  resource_id = aws_api_gateway_resource.Object.id
  http_method = aws_api_gateway_method.GetBuckets2.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_deployment" "S3APIDeployment" {
  depends_on  = [aws_api_gateway_integration.S3Integration1]
  rest_api_id = "${aws_api_gateway_rest_api.MyS3.id}"
  stage_name  = "MyS3"
}