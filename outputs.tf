output "RDSEndpoint" {
    description = "RDS Endpoint"
    value = aws_db_instance.vprofile-rds.endpoint
}

output "MemeCacheEndpoint" {
    description = "MemeCache Endpoint"
    value = aws_elasticache_cluster.vprofile-cache.configuration_endpoint
}

output "RabbitMQEndpoint" {
    description = "MemeCache Endpoint"
    value = aws_mq_broker.vprofile-rmq.instances.0.endpoints
}