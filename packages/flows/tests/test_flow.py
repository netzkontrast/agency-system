import sys
import os
import pytest
from pathlib import Path

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from flows import create_ingest_flow, create_qa_generation_flow

def test_create_ingest_flow():
    """Test that ingest flow can be created without errors"""
    flow = create_ingest_flow()
    assert flow is not None
    assert hasattr(flow, 'start')

def test_create_qa_generation_flow():
    """Test that QA generation flow can be created without errors"""
    flow = create_qa_generation_flow()
    assert flow is not None
    assert hasattr(flow, 'start')

def test_flow_nodes():
    """Test that flows contain expected nodes"""
    ingest_flow = create_ingest_flow()
    qa_flow = create_qa_generation_flow()
    
    # Check that flows have nodes
    assert ingest_flow.start is not None
    assert qa_flow.start is not None

if __name__ == "__main__":
    pytest.main([__file__])
