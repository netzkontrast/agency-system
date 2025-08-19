---
inclusion: fileMatch
fileMatchPattern: "*.py"
---

# PocketFlow Development Patterns

## Core Abstractions

### Node Structure
Every Node should follow this pattern:
```python
class ExampleNode(Node):
    def prep(self, shared):
        # Read data from shared store
        return shared["input_key"]
    
    def exec(self, prep_res):
        # Core logic - call utility functions here
        # NO exception handling - let Node retry mechanism handle failures
        return process_data(prep_res)
    
    def post(self, shared, prep_res, exec_res):
        # Write results to shared store
        shared["output_key"] = exec_res
        return "default"  # or specific action name
```

### Flow Patterns
```python
# Sequential flow
node_a >> node_b >> node_c

# Branching flow
node_a - "success" >> node_b
node_a - "retry" >> node_a  # loop back
node_a - "failure" >> error_node

# Create flow
flow = Flow(start=node_a)
```

### Shared Store Design
```python
shared = {
    "input": {
        "content": "text to process",
        "metadata": {"source": "file.txt"}
    },
    "processing": {
        "chunks": [],
        "embeddings": []
    },
    "output": {
        "results": [],
        "summary": ""
    }
}
```

## Design Patterns

### Map-Reduce Pattern
```python
class MapNode(BatchNode):
    def prep(self, shared):
        # Return iterable of items to process
        return shared["items"]
    
    def exec(self, item):
        # Process single item
        return process_item(item)
    
    def post(self, shared, prep_res, exec_res_list):
        # Combine results
        shared["mapped_results"] = exec_res_list
        return "default"

class ReduceNode(Node):
    def prep(self, shared):
        return shared["mapped_results"]
    
    def exec(self, results):
        return combine_results(results)
    
    def post(self, shared, prep_res, exec_res):
        shared["final_result"] = exec_res
        return "default"
```

### Agent Pattern
```python
class AgentNode(Node):
    def prep(self, shared):
        # Gather context for decision making
        return {
            "context": shared["context"],
            "available_actions": ["action1", "action2", "action3"]
        }
    
    def exec(self, prep_res):
        # LLM decides on action
        decision = call_llm(f"Given context: {prep_res['context']}, choose action from: {prep_res['available_actions']}")
        return decision
    
    def post(self, shared, prep_res, exec_res):
        shared["chosen_action"] = exec_res
        return exec_res  # Return action as flow transition
```

### RAG Pattern
```python
class RetrieveNode(Node):
    def prep(self, shared):
        return shared["query"]
    
    def exec(self, query):
        # Semantic search
        return vector_search(query)
    
    def post(self, shared, prep_res, exec_res):
        shared["retrieved_docs"] = exec_res
        return "default"

class GenerateNode(Node):
    def prep(self, shared):
        return {
            "query": shared["query"],
            "context": shared["retrieved_docs"]
        }
    
    def exec(self, prep_res):
        prompt = f"Query: {prep_res['query']}\nContext: {prep_res['context']}\nAnswer:"
        return call_llm(prompt)
    
    def post(self, shared, prep_res, exec_res):
        shared["answer"] = exec_res
        return "default"
```

## Utility Function Patterns

### LLM Utility
```python
# utils/call_llm.py
def call_llm(prompt: str, model: str = "default") -> str:
    # Implementation without try/except
    # Let Node handle retries
    client = get_llm_client()
    response = client.generate(prompt, model=model)
    return response.text

if __name__ == "__main__":
    # Test the utility
    result = call_llm("Hello, how are you?")
    print(result)
```

### Vector Search Utility
```python
# utils/vector_search.py
def vector_search(query: str, collection: str = "default") -> list:
    # Get embedding for query
    query_embedding = get_embedding(query)
    
    # Search in vector database
    client = get_qdrant_client()
    results = client.search(
        collection_name=collection,
        query_vector=query_embedding,
        limit=10
    )
    
    return [{"id": r.id, "content": r.payload["content"], "score": r.score} for r in results]

if __name__ == "__main__":
    results = vector_search("test query")
    print(f"Found {len(results)} results")
```

## Batch Processing Patterns

### BatchNode for Large Data
```python
class ProcessLargeDataset(BatchNode):
    def prep(self, shared):
        # Split large dataset into chunks
        data = shared["large_dataset"]
        chunk_size = 1000
        return [data[i:i+chunk_size] for i in range(0, len(data), chunk_size)]
    
    def exec(self, chunk):
        # Process single chunk
        return process_chunk(chunk)
    
    def post(self, shared, prep_res, exec_res_list):
        # Combine all chunk results
        shared["processed_data"] = flatten(exec_res_list)
        return "default"
```

### BatchFlow for Multiple Items
```python
class ProcessMultipleFiles(BatchFlow):
    def prep(self, shared):
        # Return list of param dicts for each file
        files = shared["file_list"]
        return [{"filename": f} for f in files]

# Usage
process_single_file = Flow(start=LoadFileNode() >> ProcessFileNode())
process_all_files = ProcessMultipleFiles(start=process_single_file)
```

## Error Handling Patterns

### Node-Level Retry Configuration
```python
class ReliableNode(Node):
    def __init__(self):
        super().__init__()
        self.max_retries = 3
        self.wait_time = 1.0
    
    def exec(self, prep_res):
        # This will be retried automatically on failure
        result = potentially_failing_operation(prep_res)
        
        # Add validation to trigger retries
        if not is_valid_result(result):
            raise ValueError("Invalid result - will trigger retry")
        
        return result
```

### Fallback Patterns
```python
class NodeWithFallback(Node):
    def exec(self, prep_res):
        return primary_operation(prep_res)
    
    def exec_fallback(self, prep_res):
        # Called if exec fails after all retries
        return fallback_operation(prep_res)
```

## Testing Patterns

### Node Testing
```python
def test_example_node():
    node = ExampleNode()
    shared = {"input_key": "test_data"}
    
    # Test the node
    node.run(shared)
    
    assert "output_key" in shared
    assert shared["output_key"] == expected_result
```

### Flow Testing
```python
def test_example_flow():
    flow = create_example_flow()
    shared = {"initial_data": "test"}
    
    flow.run(shared)
    
    assert shared["final_result"] == expected_final_result
```

## Performance Patterns

### Async Operations
```python
class AsyncNode(AsyncNode):
    async def exec_async(self, prep_res):
        # For I/O bound operations
        result = await async_operation(prep_res)
        return result
```

### Parallel Processing
```python
class ParallelNode(ParallelNode):
    def prep(self, shared):
        # Return items that can be processed in parallel
        return shared["parallel_items"]
    
    def exec(self, item):
        # Process single item (will run in parallel)
        return process_item(item)
```

## Logging and Debugging

### Add Logging to Nodes
```python
import logging

class LoggedNode(Node):
    def __init__(self):
        super().__init__()
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def prep(self, shared):
        self.logger.info("Starting preparation")
        result = shared["input"]
        self.logger.debug(f"Prepared data: {result}")
        return result
    
    def exec(self, prep_res):
        self.logger.info("Executing main logic")
        result = process_data(prep_res)
        self.logger.info(f"Execution completed, result length: {len(result)}")
        return result
```