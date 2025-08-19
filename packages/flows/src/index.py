# Main entry point for flows package

from .flows import create_ingest_flow, create_qa_generation_flow

__all__ = [
    "create_ingest_flow",
    "create_qa_generation_flow"
]
