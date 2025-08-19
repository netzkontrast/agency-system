---
inclusion: always
---

# Context Management Guidelines

## Context Prioritization Strategy

### Information Hierarchy
When managing context for AI interactions, prioritize information in this order:

1. **Immediate Task Context** (Highest Priority)
   - Current user request
   - Specific requirements and constraints
   - Expected output format

2. **Domain-Specific Context** (High Priority)
   - Project architecture and patterns
   - Technology stack specifics
   - Business logic and rules

3. **Historical Context** (Medium Priority)
   - Previous conversation history
   - Related past decisions
   - Learned patterns and preferences

4. **General Context** (Lower Priority)
   - Documentation references
   - Best practices
   - Background information

### Context Window Optimization

#### Token Budget Allocation
For typical 8K context window:
- **Task Context**: 1,500 tokens (18.75%)
- **Domain Context**: 3,000 tokens (37.5%)
- **Code/Examples**: 2,000 tokens (25%)
- **Historical Context**: 1,000 tokens (12.5%)
- **Buffer**: 500 tokens (6.25%)

#### Dynamic Context Adjustment
```python
class ContextManager:
    def __init__(self, max_tokens: int = 8000):
        self.max_tokens = max_tokens
        self.context_budget = {
            'task': 0.1875,      # 18.75%
            'domain': 0.375,     # 37.5%
            'code': 0.25,        # 25%
            'history': 0.125,    # 12.5%
            'buffer': 0.0625     # 6.25%
        }
    
    def allocate_context(self, contexts: dict) -> dict:
        allocated = {}
        remaining_tokens = self.max_tokens
        
        # Allocate by priority
        for context_type in ['task', 'domain', 'code', 'history']:
            if context_type in contexts:
                budget = int(self.max_tokens * self.context_budget[context_type])
                content = contexts[context_type]
                
                if len(content.split()) <= budget:
                    allocated[context_type] = content
                    remaining_tokens -= len(content.split())
                else:
                    # Intelligently truncate
                    allocated[context_type] = self.smart_truncate(content, budget)
                    remaining_tokens -= budget
        
        return allocated
    
    def smart_truncate(self, content: str, max_tokens: int) -> str:
        """Truncate while preserving structure and key information"""
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
        
        return result
```

## Context Relevance Filtering

### Semantic Relevance Scoring
```python
def calculate_relevance_score(context_item: str, current_task: str) -> float:
    """
    Calculate relevance score between context item and current task
    """
    # Simple keyword overlap (in practice, use embeddings)
    task_words = set(current_task.lower().split())
    context_words = set(context_item.lower().split())
    
    overlap = len(task_words.intersection(context_words))
    union = len(task_words.union(context_words))
    
    jaccard_similarity = overlap / union if union > 0 else 0
    
    # Boost score for domain-specific terms
    domain_terms = {
        'pocketflow', 'node', 'flow', 'shared', 'prep', 'exec', 'post',
        'qdrant', 'postgres', 'vector', 'embedding', 'semantic', 'llm'
    }
    
    domain_overlap = len(context_words.intersection(domain_terms))
    domain_boost = min(domain_overlap * 0.1, 0.3)  # Max 30% boost
    
    return min(jaccard_similarity + domain_boost, 1.0)

def filter_relevant_context(context_items: list, current_task: str, 
                          max_items: int = 5) -> list:
    """
    Filter and rank context items by relevance
    """
    scored_items = []
    for item in context_items:
        score = calculate_relevance_score(item, current_task)
        scored_items.append((item, score))
    
    # Sort by score and take top items
    scored_items.sort(key=lambda x: x[1], reverse=True)
    return [item for item, score in scored_items[:max_items]]
```

## Context Persistence and Memory

### Conversation Memory Management
```python
class ConversationMemory:
    def __init__(self, max_history: int = 10):
        self.max_history = max_history
        self.conversation_history = []
        self.important_facts = {}
        self.patterns = {}
    
    def add_interaction(self, user_input: str, ai_response: str, 
                       context_used: dict):
        interaction = {
            'timestamp': time.time(),
            'user_input': user_input,
            'ai_response': ai_response,
            'context_used': context_used,
            'tokens_used': len(f"{user_input} {ai_response}".split())
        }
        
        self.conversation_history.append(interaction)
        
        # Keep only recent history
        if len(self.conversation_history) > self.max_history:
            self.conversation_history.pop(0)
        
        # Extract important facts
        self.extract_important_facts(interaction)
    
    def extract_important_facts(self, interaction: dict):
        """Extract and store important facts from interactions"""
        # Look for decisions, preferences, and key information
        user_input = interaction['user_input'].lower()
        ai_response = interaction['ai_response'].lower()
        
        # Pattern: User preferences
        if 'prefer' in user_input or 'like' in user_input:
            self.important_facts['preferences'] = self.important_facts.get('preferences', [])
            self.important_facts['preferences'].append(user_input)
        
        # Pattern: Technical decisions
        if any(word in ai_response for word in ['implement', 'use', 'create', 'design']):
            self.important_facts['decisions'] = self.important_facts.get('decisions', [])
            self.important_facts['decisions'].append(ai_response[:200])  # First 200 chars
    
    def get_relevant_history(self, current_task: str, max_tokens: int = 1000) -> str:
        """Get relevant conversation history for current task"""
        if not self.conversation_history:
            return ""
        
        relevant_interactions = []
        total_tokens = 0
        
        # Start with most recent and work backwards
        for interaction in reversed(self.conversation_history):
            interaction_text = f"User: {interaction['user_input']}\nAI: {interaction['ai_response']}"
            interaction_tokens = len(interaction_text.split())
            
            if total_tokens + interaction_tokens <= max_tokens:
                relevance = calculate_relevance_score(interaction_text, current_task)
                if relevance > 0.2:  # Minimum relevance threshold
                    relevant_interactions.insert(0, interaction_text)
                    total_tokens += interaction_tokens
            else:
                break
        
        return "\n\n---\n\n".join(relevant_interactions)
```

## Context Injection Strategies

### Progressive Context Loading
```python
class ProgressiveContextLoader:
    def __init__(self):
        self.context_layers = {
            'core': [],      # Always included
            'relevant': [],  # Included if relevant
            'optional': []   # Included if space allows
        }
    
    def add_context(self, content: str, layer: str = 'relevant', 
                   relevance_score: float = 0.5):
        self.context_layers[layer].append({
            'content': content,
            'relevance': relevance_score,
            'tokens': len(content.split())
        })
    
    def build_context(self, current_task: str, max_tokens: int) -> str:
        context_parts = []
        used_tokens = 0
        
        # Always include core context
        for item in self.context_layers['core']:
            if used_tokens + item['tokens'] <= max_tokens:
                context_parts.append(item['content'])
                used_tokens += item['tokens']
        
        # Include relevant context by relevance score
        relevant_items = sorted(
            self.context_layers['relevant'], 
            key=lambda x: x['relevance'], 
            reverse=True
        )
        
        for item in relevant_items:
            if used_tokens + item['tokens'] <= max_tokens:
                context_parts.append(item['content'])
                used_tokens += item['tokens']
        
        # Fill remaining space with optional context
        optional_items = sorted(
            self.context_layers['optional'], 
            key=lambda x: x['relevance'], 
            reverse=True
        )
        
        for item in optional_items:
            if used_tokens + item['tokens'] <= max_tokens:
                context_parts.append(item['content'])
                used_tokens += item['tokens']
        
        return "\n\n".join(context_parts)
```

### Context Templates for Different Scenarios

#### Code Implementation Context
```python
CODE_IMPLEMENTATION_CONTEXT = """
# Current Task
{task_description}

# Architecture Context
- Framework: {framework}
- Patterns: {applicable_patterns}
- Dependencies: {dependencies}

# Code Context
{existing_code}

# Requirements
{specific_requirements}

# Constraints
{constraints}
"""
```

#### Design Review Context
```python
DESIGN_REVIEW_CONTEXT = """
# Design Under Review
{design_document}

# Requirements Alignment
{requirements_check}

# Architecture Considerations
{architecture_notes}

# Previous Feedback
{historical_feedback}

# Review Criteria
{review_criteria}
"""
```

#### Debugging Context
```python
DEBUG_CONTEXT = """
# Problem Description
{problem_description}

# Error Information
{error_details}

# Relevant Code
{code_context}

# System State
{system_state}

# Previous Attempts
{previous_attempts}

# Environment
{environment_info}
"""
```

## Context Quality Assurance

### Context Validation
```python
def validate_context_quality(context: str, task: str) -> dict:
    """
    Validate that context is appropriate and useful for the task
    """
    validation_result = {
        'quality_score': 0.0,
        'issues': [],
        'suggestions': []
    }
    
    # Check for relevance
    relevance = calculate_relevance_score(context, task)
    validation_result['quality_score'] += relevance * 0.4
    
    if relevance < 0.3:
        validation_result['issues'].append("Low relevance to current task")
        validation_result['suggestions'].append("Include more task-specific context")
    
    # Check for completeness
    context_words = len(context.split())
    if context_words < 100:
        validation_result['issues'].append("Context may be too brief")
        validation_result['suggestions'].append("Add more detailed context")
    elif context_words > 4000:
        validation_result['issues'].append("Context may be too verbose")
        validation_result['suggestions'].append("Prioritize and truncate context")
    else:
        validation_result['quality_score'] += 0.3
    
    # Check for structure
    if any(marker in context for marker in ['#', '##', '###', '- ', '1. ']):
        validation_result['quality_score'] += 0.2
    else:
        validation_result['issues'].append("Context lacks clear structure")
        validation_result['suggestions'].append("Add headers and bullet points")
    
    # Check for code examples (if relevant)
    if any(keyword in task.lower() for keyword in ['implement', 'code', 'function', 'class']):
        if '```' in context or 'def ' in context or 'class ' in context:
            validation_result['quality_score'] += 0.1
        else:
            validation_result['suggestions'].append("Include relevant code examples")
    
    return validation_result
```

### Context Optimization Feedback Loop
```python
class ContextOptimizer:
    def __init__(self):
        self.performance_history = []
    
    def record_performance(self, context_used: str, task: str, 
                         success: bool, response_quality: float):
        self.performance_history.append({
            'context': context_used,
            'task': task,
            'success': success,
            'quality': response_quality,
            'timestamp': time.time()
        })
    
    def analyze_patterns(self) -> dict:
        """Analyze what context patterns lead to better performance"""
        if len(self.performance_history) < 10:
            return {"message": "Insufficient data for analysis"}
        
        # Group by context characteristics
        structured_contexts = [p for p in self.performance_history 
                             if any(marker in p['context'] for marker in ['#', '- ', '1. '])]
        unstructured_contexts = [p for p in self.performance_history 
                               if p not in structured_contexts]
        
        structured_avg_quality = sum(p['quality'] for p in structured_contexts) / len(structured_contexts) if structured_contexts else 0
        unstructured_avg_quality = sum(p['quality'] for p in unstructured_contexts) / len(unstructured_contexts) if unstructured_contexts else 0
        
        return {
            'structured_context_performance': structured_avg_quality,
            'unstructured_context_performance': unstructured_avg_quality,
            'recommendation': 'Use structured context' if structured_avg_quality > unstructured_avg_quality else 'Context structure may not matter',
            'total_samples': len(self.performance_history)
        }
```