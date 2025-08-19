# PocketFlow Flows for Kohärenz Protokoll

from pocketflow import Flow
from .nodes import (
    ParseNode, 
    SegmentNode, 
    GenQuestionsNode, 
    GenAnswersNode, 
    EmbedNode, 
    UpsertRelateNode
)

def create_ingest_flow():
    """Create flow for ingesting content and generating QA pairs"""
    
    # Create nodes
    parse_node = ParseNode()
    segment_node = SegmentNode()
    gen_questions_node = GenQuestionsNode()
    gen_answers_node = GenAnswersNode()
    embed_node = EmbedNode()
    upsert_relate_node = UpsertRelateNode()
    
    # Connect nodes
    parse_node >> segment_node
    segment_node >> gen_questions_node
    gen_questions_node >> gen_answers_node
    gen_answers_node >> embed_node
    embed_node >> upsert_relate_node
    
    # Create flow
    return Flow(start=parse_node)

def create_qa_generation_flow():
    """Create flow for generating QA pairs from spans"""
    
    # Create nodes
    gen_questions_node = GenQuestionsNode()
    gen_answers_node = GenAnswersNode()
    embed_node = EmbedNode()
    upsert_relate_node = UpsertRelateNode()
    
    # Connect nodes
    gen_questions_node >> gen_answers_node
    gen_answers_node >> embed_node
    embed_node >> upsert_relate_node
    
    # Create flow
    return Flow(start=gen_questions_node)
