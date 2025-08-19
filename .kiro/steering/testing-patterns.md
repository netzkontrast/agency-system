---
inclusion: fileMatch
fileMatchPattern: "**/*.{test,spec}.{ts,tsx,js,jsx,py}"
---

# Testing Patterns and Standards

## Testing Philosophy

### Test-Driven Development (TDD)
For critical components, follow the TDD cycle:
1. **Red**: Write a failing test that defines desired behavior
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code while keeping tests green

### Testing Pyramid
Structure tests according to the testing pyramid:
- **Unit Tests (70%)**: Fast, isolated, test individual functions/components
- **Integration Tests (20%)**: Test component interactions and data flow
- **End-to-End Tests (10%)**: Test complete user workflows

## Node Testing Patterns

### Basic Node Testing
```python
import pytest
from unittest.mock import Mock, patch
from your_flow.nodes import ExampleNode

class TestExampleNode:
    def setup_method(self):
        self.node = ExampleNode()
        self.shared = {
            "input_data": "test content",
            "metadata": {"source": "test.txt"}
        }
    
    def test_prep_extracts_correct_data(self):
        # Arrange
        expected_data = "test content"
        
        # Act
        result = self.node.prep(self.shared)
        
        # Assert
        assert result == expected_data
    
    def test_exec_processes_data_correctly(self):
        # Arrange
        prep_result = "test content"
        expected_output = "processed: test content"
        
        # Act
        result = self.node.exec(prep_result)
        
        # Assert
        assert result == expected_output
    
    def test_post_updates_shared_store(self):
        # Arrange
        prep_result = "test content"
        exec_result = "processed: test content"
        
        # Act
        action = self.node.post(self.shared, prep_result, exec_result)
        
        # Assert
        assert "output_data" in self.shared
        assert self.shared["output_data"] == exec_result
        assert action == "default"
    
    def test_full_node_execution(self):
        # Arrange
        initial_shared = self.shared.copy()
        
        # Act
        self.node.run(self.shared)
        
        # Assert
        assert "output_data" in self.shared
        assert self.shared["output_data"] is not None
        # Verify shared store wasn't corrupted
        assert "input_data" in self.shared
```

### Testing Nodes with External Dependencies
```python
class TestLLMNode:
    def setup_method(self):
        self.node = LLMNode()
        self.shared = {
            "prompt": "Test prompt",
            "model_config": {"temperature": 0.7}
        }
    
    @patch('your_flow.utils.call_llm')
    def test_exec_calls_llm_with_correct_params(self, mock_call_llm):
        # Arrange
        mock_call_llm.return_value = "LLM response"
        prep_result = {"prompt": "Test prompt", "config": {"temperature": 0.7}}
        
        # Act
        result = self.node.exec(prep_result)
        
        # Assert
        mock_call_llm.assert_called_once_with(
            prompt="Test prompt",
            **{"temperature": 0.7}
        )
        assert result == "LLM response"
    
    @patch('your_flow.utils.call_llm')
    def test_exec_handles_llm_failure(self, mock_call_llm):
        # Arrange
        mock_call_llm.side_effect = Exception("LLM service unavailable")
        prep_result = {"prompt": "Test prompt", "config": {}}
        
        # Act & Assert
        with pytest.raises(Exception) as exc_info:
            self.node.exec(prep_result)
        
        assert "LLM service unavailable" in str(exc_info.value)
```

### Testing BatchNodes
```python
class TestBatchProcessingNode:
    def setup_method(self):
        self.node = BatchProcessingNode()
        self.shared = {
            "items": ["item1", "item2", "item3"],
            "batch_config": {"chunk_size": 2}
        }
    
    def test_prep_returns_correct_batches(self):
        # Act
        result = self.node.prep(self.shared)
        
        # Assert
        assert len(result) == 3  # 3 individual items
        assert result == ["item1", "item2", "item3"]
    
    def test_exec_processes_single_item(self):
        # Arrange
        item = "test_item"
        
        # Act
        result = self.node.exec(item)
        
        # Assert
        assert result == f"processed_{item}"
    
    def test_post_combines_results(self):
        # Arrange
        prep_result = ["item1", "item2", "item3"]
        exec_results = ["processed_item1", "processed_item2", "processed_item3"]
        
        # Act
        action = self.node.post(self.shared, prep_result, exec_results)
        
        # Assert
        assert "processed_items" in self.shared
        assert self.shared["processed_items"] == exec_results
        assert action == "default"
```

## Flow Testing Patterns

### Integration Testing for Flows
```python
class TestCompleteFlow:
    def setup_method(self):
        self.flow = create_processing_flow()
        self.shared = {
            "input_content": "Test content for processing",
            "metadata": {"source": "test.txt", "chapter": "1"}
        }
    
    def test_complete_flow_execution(self):
        # Act
        self.flow.run(self.shared)
        
        # Assert - Check final state
        assert "final_result" in self.shared
        assert "processing_steps" in self.shared
        assert len(self.shared["processing_steps"]) > 0
        
        # Verify data flow integrity
        assert self.shared["input_content"] == "Test content for processing"
        assert self.shared["metadata"]["source"] == "test.txt"
    
    @patch('your_flow.utils.call_llm')
    @patch('your_flow.utils.vector_search')
    def test_flow_with_mocked_dependencies(self, mock_vector_search, mock_call_llm):
        # Arrange
        mock_call_llm.return_value = "Generated response"
        mock_vector_search.return_value = [{"id": "1", "content": "Related content"}]
        
        # Act
        self.flow.run(self.shared)
        
        # Assert
        assert mock_call_llm.called
        assert mock_vector_search.called
        assert "final_result" in self.shared
    
    def test_flow_error_handling(self):
        # Arrange - Create invalid input
        invalid_shared = {"invalid_key": "invalid_data"}
        
        # Act & Assert
        with pytest.raises(KeyError):
            self.flow.run(invalid_shared)
```

### Testing Flow Branching
```python
class TestConditionalFlow:
    def setup_method(self):
        self.flow = create_conditional_flow()
    
    def test_success_path(self):
        # Arrange
        shared = {"input": "valid_input", "condition": True}
        
        # Act
        self.flow.run(shared)
        
        # Assert
        assert shared["path_taken"] == "success"
        assert "success_result" in shared
    
    def test_failure_path(self):
        # Arrange
        shared = {"input": "invalid_input", "condition": False}
        
        # Act
        self.flow.run(shared)
        
        # Assert
        assert shared["path_taken"] == "failure"
        assert "error_handled" in shared
    
    def test_retry_mechanism(self):
        # Arrange
        shared = {"input": "retry_input", "attempt_count": 0}
        
        # Act
        self.flow.run(shared)
        
        # Assert
        assert shared["attempt_count"] > 1
        assert shared["final_status"] in ["success", "max_retries_reached"]
```

## API Testing Patterns

### Next.js API Route Testing
```typescript
import { NextRequest } from 'next/server';
import { POST } from '@/app/api/ingest/route';

describe('/api/ingest', () => {
  it('should process valid ingest request', async () => {
    // Arrange
    const requestBody = {
      content: "Test content for ingestion",
      metadata: {
        source: "test.txt",
        chapter: "1"
      }
    };
    
    const request = new NextRequest('http://localhost:3000/api/ingest', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody)
    });
    
    // Act
    const response = await POST(request);
    const data = await response.json();
    
    // Assert
    expect(response.status).toBe(200);
    expect(data.success).toBe(true);
    expect(data.message).toContain('ingested successfully');
    expect(data.data).toBeDefined();
  });
  
  it('should reject invalid request', async () => {
    // Arrange
    const invalidBody = {
      content: "", // Invalid: empty content
      metadata: {} // Invalid: missing source
    };
    
    const request = new NextRequest('http://localhost:3000/api/ingest', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(invalidBody)
    });
    
    // Act
    const response = await POST(request);
    const data = await response.json();
    
    // Assert
    expect(response.status).toBe(400);
    expect(data.success).toBe(false);
    expect(data.code).toBe('VALIDATION_ERROR');
    expect(data.details).toBeDefined();
  });
  
  it('should handle server errors gracefully', async () => {
    // Arrange - Mock a server error
    jest.spyOn(console, 'error').mockImplementation(() => {});
    
    const request = new NextRequest('http://localhost:3000/api/ingest', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: 'invalid json'
    });
    
    // Act
    const response = await POST(request);
    const data = await response.json();
    
    // Assert
    expect(response.status).toBe(400);
    expect(data.success).toBe(false);
    expect(data.code).toBe('PARSE_ERROR');
  });
});
```

### Database Integration Testing
```typescript
import { queryDatabase, insertSpan } from '@/lib/database';

describe('Database Operations', () => {
  beforeEach(async () => {
    // Setup test database state
    await queryDatabase('DELETE FROM test_spans');
  });
  
  afterEach(async () => {
    // Cleanup test data
    await queryDatabase('DELETE FROM test_spans');
  });
  
  it('should insert and retrieve span', async () => {
    // Arrange
    const spanData = {
      content: "Test span content",
      metadata: { source: "test.txt" }
    };
    
    // Act
    const insertResult = await insertSpan(spanData.content, spanData.metadata);
    const retrievedSpans = await queryDatabase(
      'SELECT * FROM spans WHERE id = $1',
      [insertResult.id]
    );
    
    // Assert
    expect(insertResult.id).toBeDefined();
    expect(retrievedSpans).toHaveLength(1);
    expect(retrievedSpans[0].content).toBe(spanData.content);
  });
});
```

## Frontend Testing Patterns

### Component Testing with React Testing Library
```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryInterface } from '@/components/QueryInterface';

describe('QueryInterface', () => {
  it('should render query input and button', () => {
    // Act
    render(<QueryInterface />);
    
    // Assert
    expect(screen.getByPlaceholderText('Enter your question...')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /search/i })).toBeInTheDocument();
  });
  
  it('should handle query submission', async () => {
    // Arrange
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({
        success: true,
        data: {
          answers: [{ id: '1', content: 'Test answer', type: 'short', citations: [] }],
          citations: []
        }
      })
    });
    
    render(<QueryInterface />);
    
    // Act
    const input = screen.getByPlaceholderText('Enter your question...');
    const button = screen.getByRole('button', { name: /search/i });
    
    fireEvent.change(input, { target: { value: 'test query' } });
    fireEvent.click(button);
    
    // Assert
    await waitFor(() => {
      expect(screen.getByText('Test answer')).toBeInTheDocument();
    });
    
    expect(global.fetch).toHaveBeenCalledWith('/api/query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question: 'test query' })
    });
  });
  
  it('should handle loading state', async () => {
    // Arrange
    global.fetch = jest.fn().mockImplementation(
      () => new Promise(resolve => setTimeout(resolve, 100))
    );
    
    render(<QueryInterface />);
    
    // Act
    const input = screen.getByPlaceholderText('Enter your question...');
    const button = screen.getByRole('button', { name: /search/i });
    
    fireEvent.change(input, { target: { value: 'test query' } });
    fireEvent.click(button);
    
    // Assert
    expect(screen.getByText('Searching...')).toBeInTheDocument();
    expect(button).toBeDisabled();
  });
});
```

## Performance Testing

### Load Testing for APIs
```typescript
import { performance } from 'perf_hooks';

describe('API Performance', () => {
  it('should respond within acceptable time limits', async () => {
    // Arrange
    const requestBody = {
      content: "Test content",
      metadata: { source: "test.txt" }
    };
    
    const startTime = performance.now();
    
    // Act
    const response = await fetch('/api/ingest', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody)
    });
    
    const endTime = performance.now();
    const responseTime = endTime - startTime;
    
    // Assert
    expect(response.status).toBe(200);
    expect(responseTime).toBeLessThan(5000); // 5 seconds max
  });
  
  it('should handle concurrent requests', async () => {
    // Arrange
    const requestCount = 10;
    const requests = Array(requestCount).fill(null).map(() => 
      fetch('/api/query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: 'test query' })
      })
    );
    
    // Act
    const startTime = performance.now();
    const responses = await Promise.all(requests);
    const endTime = performance.now();
    
    // Assert
    responses.forEach(response => {
      expect(response.status).toBe(200);
    });
    
    const totalTime = endTime - startTime;
    const avgResponseTime = totalTime / requestCount;
    expect(avgResponseTime).toBeLessThan(2000); // 2 seconds average
  });
});
```

## Test Data Management

### Test Fixtures
```python
# conftest.py
import pytest

@pytest.fixture
def sample_content():
    return {
        "content": "This is a test content for processing.",
        "metadata": {
            "source": "test.txt",
            "chapter": "chapter_1",
            "beat": "opening"
        }
    }

@pytest.fixture
def mock_llm_response():
    return {
        "questions": [
            {
                "question": "What is being tested?",
                "type": "factual",
                "keywords": ["test", "content", "processing"]
            }
        ],
        "answers": {
            "short": "Test content processing",
            "mid": "This is test content for processing [span_1]",
            "long": "This comprehensive test content demonstrates processing capabilities [span_1]",
            "citations": ["span_1"]
        }
    }

@pytest.fixture
def shared_store_template():
    return {
        "input": {},
        "processing": {
            "spans": [],
            "questions": [],
            "answers": [],
            "embeddings": []
        },
        "output": {
            "results": [],
            "summary": ""
        }
    }
```

### Database Test Utilities
```python
# test_utils.py
import asyncio
from typing import Dict, Any

class DatabaseTestHelper:
    def __init__(self, db_connection):
        self.db = db_connection
    
    async def setup_test_data(self, data: Dict[str, Any]):
        """Setup test data in database"""
        for table, records in data.items():
            for record in records:
                await self.insert_record(table, record)
    
    async def cleanup_test_data(self, tables: list):
        """Clean up test data from specified tables"""
        for table in tables:
            await self.db.execute(f"DELETE FROM {table} WHERE source LIKE 'test_%'")
    
    async def insert_record(self, table: str, record: Dict[str, Any]):
        """Insert a single test record"""
        columns = ', '.join(record.keys())
        placeholders = ', '.join(['$' + str(i+1) for i in range(len(record))])
        query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
        await self.db.execute(query, *record.values())
```

## Continuous Integration Testing

### GitHub Actions Test Configuration
```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'pnpm'
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pnpm install
        pip install -r requirements.txt
    
    - name: Run Python tests
      run: pytest --cov=. --cov-report=xml
      env:
        DATABASE_URL: postgresql://postgres:test@localhost:5432/test_db
    
    - name: Run TypeScript tests
      run: pnpm test
      env:
        NODE_ENV: test
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

## Test Quality Metrics

### Coverage Requirements
- **Unit Tests**: Minimum 80% code coverage
- **Integration Tests**: Cover all critical user paths
- **API Tests**: Cover all endpoints and error conditions
- **Frontend Tests**: Cover all user interactions

### Test Performance Standards
- **Unit Tests**: Should run in < 100ms each
- **Integration Tests**: Should run in < 5 seconds each
- **Full Test Suite**: Should complete in < 10 minutes
- **Flaky Tests**: Zero tolerance - fix or remove immediately