# PocketFlow Nodes for Kohärenz Protokoll

from pocketflow import Node, BatchNode
from typing import List, Dict, Any, Tuple
import re

class ParseNode(Node):
    """Parse text content into spans"""
    
    def prep(self, shared):
        # Extract content from shared store
        return shared.get("content", "")
    
    def exec(self, content: str) -> List[Dict[str, Any]]:
        # Simple paragraph-based parsing
        paragraphs = [p.strip() for p in content.split("\n\n") if p.strip()]
        
        spans = []
        for i, paragraph in enumerate(paragraphs):
            span = {
                "id": f"span_{i}",
                "content": paragraph,
                "metadata": {
                    "position": i,
                    "length": len(paragraph)
                }
            }
            spans.append(span)
        
        return spans
    
    def post(self, shared, prep_res, exec_res):
        # Store parsed spans in shared store
        shared["spans"] = exec_res
        return "default"

class SegmentNode(BatchNode):
    """Segment spans into chunks based on semantic clustering"""
    
    def prep(self, shared):
        # Get spans from shared store
        return shared.get("spans", [])
    
    def exec(self, span: Dict[str, Any]) -> Dict[str, Any]:
        # For now, we'll just return the span as-is
        # In a real implementation, this would apply clustering/segmentation logic
        return span
    
    def post(self, shared, prep_res, exec_res_list):
        # Store segmented spans
        shared["segmented_spans"] = exec_res_list
        return "default"

class GenQuestionsNode(BatchNode):
    """Generate atomic questions from spans"""
    
    def prep(self, shared):
        # Get segmented spans from shared store
        return shared.get("segmented_spans", [])
    
    def exec(self, span: Dict[str, Any]) -> List[Dict[str, Any]]:
        # In a real implementation, this would use an LLM to generate questions
        # For now, we'll generate mock questions
        questions = []
        for i in range(3):  # Generate 3 questions per span
            question = {
                "id": f"q_{span['id']}_{i}",
                "content": f"Question {i+1} about {span['id'][:20]}...",
                "type": "atomic",
                "span_id": span["id"]
            }
            questions.append(question)
        
        return questions
    
    def post(self, shared, prep_res, exec_res_list):
        # Flatten list of question lists
        questions = [q for qlist in exec_res_list for q in qlist]
        shared["questions"] = questions
        return "default"

class GenAnswersNode(BatchNode):
    """Generate Short/Mid/Long answers for questions"""
    
    def prep(self, shared):
        # Get questions from shared store
        return shared.get("questions", [])
    
    def exec(self, question: Dict[str, Any]) -> List[Dict[str, Any]]:
        # In a real implementation, this would use an LLM to generate answers
        # For now, we'll generate mock answers
        answer_types = ["short", "mid", "long"]
        answers = []
        
        for answer_type in answer_types:
            answer = {
                "id": f"ans_{question['id']}_{answer_type}",
                "question_id": question["id"],
                "content": f"This is a {answer_type} answer to {question['content'][:30]}...",
                "type": answer_type,
                "citations": [question["span_id"]]  # Link to source span
            }
            answers.append(answer)
        
        return answers
    
    def post(self, shared, prep_res, exec_res_list):
        # Flatten list of answer lists
        answers = [a for alist in exec_res_list for a in alist]
        shared["answers"] = answers
        return "default"

class EmbedNode(BatchNode):
    """Generate embeddings for spans, questions, and answers"""
    
    def prep(self, shared):
        # Prepare items to embed: spans, questions, answers
        spans = shared.get("spans", [])
        questions = shared.get("questions", [])
        answers = shared.get("answers", [])
        
        items_to_embed = []
        
        # Add spans
        for span in spans:
            items_to_embed.append({
                "id": f"span_emb_{span['id']}",
                "type": "span",
                "content": span["content"],
                "source_id": span["id"]
            })
        
        # Add questions
        for question in questions:
            items_to_embed.append({
                "id": f"question_emb_{question['id']}",
                "type": "question",
                "content": question["content"],
                "source_id": question["id"]
            })
        
        # Add answers
        for answer in answers:
            items_to_embed.append({
                "id": f"answer_emb_{answer['id']}",
                "type": "answer",
                "content": answer["content"],
                "source_id": answer["id"]
            })
        
        return items_to_embed
    
    def exec(self, item: Dict[str, Any]) -> Dict[str, Any]:
        # In a real implementation, this would use an embedding model
        # For now, we'll generate mock embeddings (1536-dimensional)
        import random
        embedding = [random.random() for _ in range(1536)]
        
        return {
            "id": item["id"],
            "type": item["type"],
            "source_id": item["source_id"],
            "vector": embedding
        }
    
    def post(self, shared, prep_res, exec_res_list):
        shared["embeddings"] = exec_res_list
        return "default"

class UpsertRelateNode(Node):
    """Upsert vectors to Qdrant and relate entities in Postgres"""
    
    def prep(self, shared):
        # Get embeddings and relations from shared store
        embeddings = shared.get("embeddings", [])
        questions = shared.get("questions", [])
        answers = shared.get("answers", [])
        
        return {
            "embeddings": embeddings,
            "questions": questions,
            "answers": answers
        }
    
    def exec(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # In a real implementation, this would:
        # 1. Upsert vectors to Qdrant collections
        # 2. Create relations in Postgres (question-span, tag-question, etc.)
        # For now, we'll just return mock results
        
        return {
            "qdrant_upserted": len(data["embeddings"]),
            "postgres_relations": len(data["questions"]) + len(data["answers"])
        }
    
    def post(self, shared, prep_res, exec_res):
        shared["upsert_result"] = exec_res
        return "default"
