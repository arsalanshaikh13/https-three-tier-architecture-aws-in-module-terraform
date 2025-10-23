terraform {
  backend "s3" {
    bucket         = "panda-backend"
    key            = "backend/panda-app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "panda-lock-table"
    use_lockfile   = true
  }
}