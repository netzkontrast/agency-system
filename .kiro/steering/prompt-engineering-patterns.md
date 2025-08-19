---
inclusion: fileMatch
fileMatchPattern: "**/*.{py,ts,tsx,js,jsx}"
---

# Prompt Engineering Patterns

## Core Prompt Design Principles

### Structured Prompt Templates
Always use structured prompts with clear sections and consistent formatting:

```python
from typing import List, Dict, Optional
import json

def create_structured_prompt(
    task: str, 
    context: str, 
    examples: Optional[List[str]] = None,
    constraints: Optional[List[str]] = None,
    output_format: Optional[str] = None
) -> str:
    """
    Create a well-structured prompt with consistent formatting
    """
    prompt_parts = [
        "# Task",
        task,
        "",
        "# Context", 
        context,
        ""
    ]
    
    if constraints:
        prompt_parts.extend([
            "# Constraints",
            *[f"- {constraint}" for constraint in constraints],
            ""
        ])
    
    if examples:
        prompt_parts.extend([
            "# Examples",
            *examples,
            ""
        ])
    
    if output_format:
        prompt_parts.extend([
            "# Output Format",
            output_format,
            ""
        ])
    
    prompt_parts.extend([
        "# Instructions",
        "- Be precise and accurate",
        "- Follow the specified format exactly",
        "- Base responses on provided context only",
        "- If information is missing, indicate clearly",
        "",
        "# Response:"
    ])
    
    return "\n".join(prompt_parts)

# Advanced prompt builder for complex scenarios
class PromptBuilder:
    def __init__(self):
        self.sections = {}
        self.order = []
    
    def add_section(self, name: str, content: str, priority: int = 1):
        self.sections[name] = {
            'content': content,
            'priority': priority
        }
        if name not in self.order:
            self.order.append(name)
    
    def build(self, max_tokens: int = 4000) -> str:
        # Sort sections by priority
        sorted_sections = sorted(
            self.sections.items(),
            key=lambda x: x[1]['priority']
        )
        
        prompt_parts = []
        token_count = 0
        
        for name, section in sorted_sections:
            section_text = f"# {name.title()}\n{section['content']}\n"
            section_tokens = len(section_text.split())
            
            if token_count + section_tokens <= max_tokens:
                prompt_parts.append(section_text)
                token_count += section_tokens
            else:
                # Try to fit a truncated version
                remaining_tokens = max_tokens - token_count - 50  # Buffer
                if remaining_tokens > 100:
                    truncated = self.truncate_content(section['content'], remaining_tokens)
                    prompt_parts.append(f"# {name.title()}\n{truncated}\n")
                break
        
        return "\n".join(prompt_parts)
    
    def truncate_content(self, content: str, max_tokens: int) -> str:
        words = content.split()
        if len(words) <= max_tokens:
            return content
        
        # Try to preserve complete sentences
        sentences = content.split('. ')
        truncated_sentences = []
        token_count = 0
        
        for sentence in sentences:
            sentence_tokens = len(sentence.split())
            if token_count + sentence_tokens <= max_tokens:
                truncated_sentences.append(sentence)
                token_count += sentence_tokens
            else:
                break
        
        result = '. '.join(truncated_sentences)
        if not result.endswith('.'):
            result += '.'
        
        return result + "\n\n[Content truncated due to length...]"
```

### Context Window Management
For the Kohärenz Protokoll's knowledge processing:

```python
def manage_context_window(content: str, max_tokens: int = 4000) -> str:
    """
    Intelligently truncate content while preserving key information
    """
    if len(content.split()) <= max_tokens:
        return content
    
    # Priority order for content preservation
    sections = extract_sections(content)
    preserved_content = []
    token_count = 0
    
    # Always preserve: title, summary, key points
    for section_type in ['title', 'summary', 'key_points', 'main_content']:
        if section_type in sections:
            section_tokens = len(sections[section_type].split())
            if token_count + section_tokens <= max_tokens:
                preserved_content.append(sections[section_type])
                token_count += section_tokens
            else:
                # Truncate this section to fit
                remaining_tokens = max_tokens - token_count
                truncated = truncate_intelligently(sections[section_type], remaining_tokens)
                preserved_content.append(truncated)
                break
    
    return "\n\n".join(preserved_content)
```

## Domain-Specific Prompt Patterns

### Content Ingestion Prompts
```python
PARSE_CONTENT_PROMPT = """
# Task
Parse the following content into semantic spans that can be independently understood and queried.

# Context
This content is part of the Kohärenz Protokoll knowledge base. Each span should:
- Be self-contained and meaningful
- Contain 1-3 sentences typically
- Preserve important context and relationships
- Be suitable for generating questions and answers

# Content
{content}

# Instructions
- Split into logical semantic units
- Preserve narrative flow and context
- Mark any cross-references or dependencies
- Return as JSON array with span_id, content, and metadata

# Response Format
```json
[
  {
    "span_id": "unique_identifier",
    "content": "semantic span text",
    "metadata": {
      "type": "narrative|dialogue|description|action",
      "chapter": "chapter_name",
      "beat": "story_beat",
      "dependencies": ["span_id1", "span_id2"]
    }
  }
]
```
"""

def create_parse_prompt(content: str, metadata: dict) -> str:
    return PARSE_CONTENT_PROMPT.format(
        content=manage_context_window(content),
        **metadata
    )
```

### Question Generation Prompts
```python
GENERATE_QUESTIONS_PROMPT = """
# Task
Generate atomic, answerable questions from the given content span.

# Context
These questions will be used for semantic search and knowledge retrieval in the Kohärenz Protokoll system.

# Quality Requirements
- Maximum 3 questions per span
- Each question must be answerable from the span content
- Questions should cover different aspects (who, what, when, where, why, how)
- Avoid yes/no questions
- Focus on factual, specific information

# Content Span
{span_content}

# Metadata
Chapter: {chapter}
Beat: {beat}
Type: {content_type}

# Instructions
Generate questions that would help users find this information through search.
Consider what someone might ask to discover this content.

# Response Format
```json
[
  {
    "question": "specific question text",
    "type": "factual|conceptual|procedural",
    "keywords": ["key", "terms", "for", "search"]
  }
]
```
"""
```

### Answer Generation Prompts
```python
GENERATE_ANSWERS_PROMPT = """
# Task
Generate three types of answers (short, mid, long) for the given question based on the provided content.

# Context
This is for the Kohärenz Protokoll knowledge system. Answers will be used for different user needs:
- Short: Quick facts, 1-2 sentences
- Mid: Detailed explanation with context, 3-5 sentences, MUST include citations
- Long: Comprehensive coverage, multiple paragraphs

# Question
{question}

# Source Content
{content}

# Citation Requirements
- Mid answers MUST have at least 1 citation
- Long answers should have multiple citations
- Use [span_id] format for citations
- Only cite content that directly supports the answer

# Instructions
- Base answers strictly on provided content
- Don't add external knowledge
- Ensure factual accuracy
- Make mid answers self-contained with proper context

# Response Format
```json
{
  "short": "brief answer text",
  "mid": "detailed answer with context [span_123]",
  "long": "comprehensive answer with multiple citations [span_123] [span_456]",
  "citations": ["span_123", "span_456"]
}
```
"""
```

### Semantic Search Prompts
```python
QUERY_EXPANSION_PROMPT = """
# Task
Expand the user query to improve semantic search results.

# Context
The Kohärenz Protokoll uses vector search on content spans. Help improve recall by:
- Adding synonyms and related terms
- Considering different phrasings
- Including domain-specific terminology

# Original Query
{original_query}

# Instructions
- Maintain the original intent
- Add 3-5 alternative phrasings
- Include relevant synonyms
- Consider both specific and general terms

# Response Format
```json
{
  "original": "user's original query",
  "expanded": [
    "alternative phrasing 1",
    "alternative phrasing 2", 
    "synonym-based version",
    "more specific version",
    "more general version"
  ],
  "keywords": ["key", "terms", "to", "boost"]
}
```
"""
```

## Context-Aware Prompt Engineering

### Persona-Specific Prompts
```python
def create_persona_prompt(base_prompt: str, persona: dict) -> str:
    """
    Adapt prompts based on persona characteristics
    """
    persona_context = f"""
# Persona Context
Name: {persona['name']}
Description: {persona['description']}
Perspective: {persona.get('perspective', 'neutral')}
Knowledge Focus: {persona.get('focus_areas', [])}

# Adaptation Instructions
- Frame responses from this persona's perspective
- Use terminology and concepts familiar to this persona
- Consider their likely interests and concerns
- Maintain their characteristic voice and approach
"""
    
    return f"{persona_context}\n\n{base_prompt}"
```

### Progressive Context Building
```python
class ContextBuilder:
    def __init__(self, max_context_tokens: int = 8000):
        self.max_tokens = max_context_tokens
        self.context_layers = []
    
    def add_layer(self, layer_name: str, content: str, priority: int = 1):
        """Add context layer with priority (1=highest)"""
        self.context_layers.append({
            'name': layer_name,
            'content': content,
            'priority': priority,
            'tokens': len(content.split())
        })
    
    def build_context(self) -> str:
        """Build context respecting token limits"""
        # Sort by priority
        sorted_layers = sorted(self.context_layers, key=lambda x: x['priority'])
        
        context_parts = []
        total_tokens = 0
        
        for layer in sorted_layers:
            if total_tokens + layer['tokens'] <= self.max_tokens:
                context_parts.append(f"## {layer['name']}\n{layer['content']}")
                total_tokens += layer['tokens']
            else:
                # Try to fit a truncated version
                remaining_tokens = self.max_tokens - total_tokens
                if remaining_tokens > 100:  # Minimum useful size
                    truncated = truncate_intelligently(layer['content'], remaining_tokens)
                    context_parts.append(f"## {layer['name']}\n{truncated}")
                break
        
        return "\n\n".join(context_parts)
```

## Error Handling and Validation

### Prompt Response Validation
```python
def validate_llm_response(response: str, expected_format: str) -> dict:
    """
    Validate LLM responses against expected formats
    """
    validation_result = {
        'valid': False,
        'errors': [],
        'parsed_data': None
    }
    
    try:
        if expected_format == 'json':
            import json
            parsed = json.loads(response)
            validation_result['parsed_data'] = parsed
            validation_result['valid'] = True
        elif expected_format == 'structured_text':
            # Validate structured text format
            if not response.strip():
                validation_result['errors'].append("Empty response")
            else:
                validation_result['valid'] = True
                validation_result['parsed_data'] = response
    except json.JSONDecodeError as e:
        validation_result['errors'].append(f"Invalid JSON: {e}")
    except Exception as e:
        validation_result['errors'].append(f"Validation error: {e}")
    
    return validation_result
```

### Retry Prompts for Failed Responses
```python
RETRY_PROMPT_TEMPLATE = """
# Previous Response Issue
The previous response had the following problems:
{error_description}

# Original Task
{original_prompt}

# Additional Instructions
- Please fix the identified issues
- Ensure proper formatting
- Double-check your response before submitting

# Corrected Response:
"""

def create_retry_prompt(original_prompt: str, errors: list) -> str:
    error_description = "\n".join([f"- {error}" for error in errors])
    return RETRY_PROMPT_TEMPLATE.format(
        error_description=error_description,
        original_prompt=original_prompt
    )
```

## Performance Optimization

### Prompt Caching Strategies
```python
def create_cacheable_prompt(base_template: str, variable_parts: dict) -> tuple:
    """
    Separate static and dynamic parts for caching
    """
    # Static part (cacheable)
    static_prompt = base_template.split("{")[0]  # Everything before first variable
    
    # Dynamic part (not cacheable)
    dynamic_content = "\n".join([f"{k}: {v}" for k, v in variable_parts.items()])
    
    return static_prompt, dynamic_content

# Usage in Node
class OptimizedLLMNode(Node):
    def __init__(self):
        super().__init__()
        self.prompt_cache = {}
    
    def exec(self, prep_res):
        static_prompt, dynamic_content = create_cacheable_prompt(
            self.prompt_template, 
            prep_res
        )
        
        # Check cache for static part
        if static_prompt in self.prompt_cache:
            cached_context = self.prompt_cache[static_prompt]
            full_prompt = f"{cached_context}\n\n{dynamic_content}"
        else:
            full_prompt = f"{static_prompt}\n\n{dynamic_content}"
            self.prompt_cache[static_prompt] = static_prompt
        
        return call_llm(full_prompt)
```

## Monitoring and Analytics

### Prompt Performance Tracking
```python
import time
from typing import Dict, List

class PromptMetrics:
    def __init__(self):
        self.metrics = {}
    
    def track_prompt(self, prompt_type: str, prompt: str, response: str, 
                    execution_time: float, success: bool):
        if prompt_type not in self.metrics:
            self.metrics[prompt_type] = {
                'total_calls': 0,
                'success_rate': 0,
                'avg_response_time': 0,
                'avg_prompt_length': 0,
                'avg_response_length': 0
            }
        
        metrics = self.metrics[prompt_type]
        metrics['total_calls'] += 1
        
        # Update running averages
        n = metrics['total_calls']
        metrics['avg_response_time'] = (
            (metrics['avg_response_time'] * (n-1) + execution_time) / n
        )
        metrics['avg_prompt_length'] = (
            (metrics['avg_prompt_length'] * (n-1) + len(prompt)) / n
        )
        metrics['avg_response_length'] = (
            (metrics['avg_response_length'] * (n-1) + len(response)) / n
        )
        
        # Update success rate
        current_successes = metrics['success_rate'] * (n-1)
        new_successes = current_successes + (1 if success else 0)
        metrics['success_rate'] = new_successes / n
    
    def get_report(self) -> Dict:
        return self.metrics

# Usage in Nodes
prompt_metrics = PromptMetrics()

class MetricsTrackingNode(Node):
    def exec(self, prep_res):
        start_time = time.time()
        prompt = self.create_prompt(prep_res)
        
        try:
            response = call_llm(prompt)
            execution_time = time.time() - start_time
            
            prompt_metrics.track_prompt(
                prompt_type=self.__class__.__name__,
                prompt=prompt,
                response=response,
                execution_time=execution_time,
                success=True
            )
            
            return response
            
        except Exception as e:
            execution_time = time.time() - start_time
            prompt_metrics.track_prompt(
                prompt_type=self.__class__.__name__,
                prompt=prompt,
                response="",
                execution_time=execution_time,
                success=False
            )
            raise e
```