terraform {
  backend "s3" {
    bucket         = "tfstate-for-locking-cadt" # Created & Versioning Enabled Manually.
    key            = "terraform.tfstate"   # path and name of state file.
    region         = "ap-southeast-1"
    use_lockfile   = false
    # dynamodb_table = "state_table" # name of dynamodb table for State Lock, must have partition key = "LockID"
    # encrypt = true # by default
  }
}
