### SECRET MANAGER
data "aws_secretsmanager_secret" "telegram-bot-token-secret" {
  name = "BOT_TOKEN"
}

data "aws_secretsmanager_secret_version" "telegram-bot-token" {
  secret_id = data.aws_secretsmanager_secret.telegram-bot-token-secret.id
}

data "aws_secretsmanager_secret" "telegram-chat-id-secret" {
  name = "CHAT_ID"
}

data "aws_secretsmanager_secret_version" "telegram-chat-id" {
  secret_id = data.aws_secretsmanager_secret.telegram-chat-id-secret.id
}
