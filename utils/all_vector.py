from qdrant_client import QdrantClient

qdrant_client = QdrantClient(
    url="https://614e302a-3f6f-4911-bece-a416da3980f9.us-west-2-0.aws.cloud.qdrant.io:6333", 
    api_key="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.M90Bb4RL92ciCfQCnG1uuAUgc6amILQHNR7m8SvWrUA",
)

print(qdrant_client.get_collections())