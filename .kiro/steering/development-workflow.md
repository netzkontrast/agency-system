---
inclusion: manual
---

# Development Workflow Guidelines

## Spec-Driven Development Process

### Phase 1: Requirements Gathering
When starting any new feature or significant change:

1. **Create Requirements Document**
   ```markdown
   # Requirements Document
   
   ## Introduction
   Brief description of the feature and its purpose
   
   ## Requirements
   
   ### Requirement 1
   **User Story:** As a [role], I want [feature], so that [benefit]
   
   #### Acceptance Criteria
   1. WHEN [event] THEN [system] SHALL [response]
   2. IF [precondition] THEN [system] SHALL [response]
   ```

2. **Requirements Review Checklist**
   - [ ] All user stories follow the standard format
   - [ ] Acceptance criteria use EARS format
   - [ ] Edge cases are considered
   - [ ] Success criteria are measurable
   - [ ] Requirements are testable

### Phase 2: Design Document Creation
After requirements approval:

1. **Research Phase**
   - Identify knowledge gaps
   - Research technical approaches
   - Analyze existing codebase patterns
   - Document findings in conversation

2. **Design Document Structure**
   ```markdown
   # Design Document
   
   ## Overview
   High-level summary of the solution
   
   ## Architecture
   System components and their interactions
   
   ## Components and Interfaces
   Detailed component specifications
   
   ## Data Models
   Data structures and relationships
   
   ## Error Handling
   Error scenarios and recovery strategies
   
   ## Testing Strategy
   How the solution will be tested
   ```

3. **Design Review Checklist**
   - [ ] Addresses all requirements
   - [ ] Follows project architecture patterns
   - [ ] Includes mermaid diagrams where helpful
   - [ ] Considers scalability and performance
   - [ ] Documents design decisions and rationales

### Phase 3: Implementation Planning
After design approval:

1. **Task Breakdown Principles**
   - Each task should be completable in 1-2 hours
   - Tasks should build incrementally
   - No orphaned code - everything integrates
   - Focus only on coding tasks
   - Reference specific requirements

2. **Task Format**
   ```markdown
   - [ ] 1. Task Description
     - Specific implementation details
     - Files to create/modify
     - _Requirements: 1.1, 2.3_
   ```

3. **Implementation Checklist**
   - [ ] All tasks are coding-focused
   - [ ] Each task references requirements
   - [ ] Tasks follow logical sequence
   - [ ] No deployment or user testing tasks
   - [ ] Test-driven development where appropriate

## Code Review and Quality Standards

### Pre-Implementation Checklist
Before starting any coding task:

- [ ] Requirements document exists and is approved
- [ ] Design document exists and is approved
- [ ] Task is clearly defined with acceptance criteria
- [ ] Dependencies are identified and available
- [ ] Development environment is set up

### During Implementation
- [ ] Follow established patterns from steering documents
- [ ] Write minimal, focused code
- [ ] Add appropriate logging
- [ ] No exception handling in utility functions
- [ ] Use shared store pattern for data flow

### Post-Implementation Review
- [ ] Code follows project patterns
- [ ] All acceptance criteria are met
- [ ] Tests are written and passing
- [ ] Documentation is updated
- [ ] No breaking changes without approval

## Git Workflow

### Branch Naming Convention
- `feature/spec-name-task-number` - For spec-driven features
- `fix/issue-description` - For bug fixes
- `docs/update-description` - For documentation updates

### Commit Message Format
```
type(scope): brief description

Longer description if needed

- Requirement: REQ-1.1
- Task: Implement user authentication
- Files: auth.py, user.py
```

### Pull Request Template
```markdown
## Changes
Brief description of what was implemented

## Requirements Addressed
- REQ-1.1: User authentication
- REQ-2.3: Session management

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project patterns
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Steering guidelines followed
```

## Testing Strategy

### Test-Driven Development for Nodes
```python
def test_example_node():
    # Arrange
    node = ExampleNode()
    shared = {"input_key": "test_data"}
    expected_output = "processed_test_data"
    
    # Act
    node.run(shared)
    
    # Assert
    assert "output_key" in shared
    assert shared["output_key"] == expected_output
    assert node.last_action == "default"
```

### Integration Testing for Flows
```python
def test_complete_flow():
    # Arrange
    flow = create_example_flow()
    shared = {"initial_data": "test_input"}
    
    # Act
    flow.run(shared)
    
    # Assert
    assert shared["final_result"] is not None
    assert shared["processing_steps"] == ["parse", "process", "output"]
```

### API Testing Patterns
```typescript
describe('API Endpoint', () => {
  it('should process valid request', async () => {
    const response = await fetch('/api/endpoint', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ test: 'data' })
    });
    
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data.message).toBe('Success');
  });
});
```

## Documentation Standards

### Code Documentation
- All public functions must have docstrings
- Complex algorithms need inline comments
- API endpoints need OpenAPI/Swagger documentation
- Database schemas need migration documentation

### Architecture Documentation
- Update architecture diagrams when adding new components
- Document integration points between services
- Maintain API documentation with examples
- Keep deployment and setup instructions current

## Performance and Monitoring

### Performance Considerations
- Monitor token usage in LLM calls
- Track database query performance
- Measure API response times
- Monitor memory usage in batch operations

### Logging Standards
```python
import logging

logger = logging.getLogger(__name__)

class ExampleNode(Node):
    def prep(self, shared):
        logger.info(f"Starting {self.__class__.__name__} preparation")
        # ... implementation
        logger.debug(f"Prepared data: {len(data)} items")
        return data
    
    def exec(self, prep_res):
        logger.info(f"Executing {self.__class__.__name__}")
        # ... implementation
        logger.info(f"Execution completed successfully")
        return result
```

### Error Handling Strategy
- Let PocketFlow handle Node retries
- Log errors with sufficient context
- Use structured logging for better analysis
- Monitor error rates and patterns

## Deployment and Release

### Pre-Deployment Checklist
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Environment variables are configured
- [ ] Database migrations are ready
- [ ] Monitoring is in place

### Release Process
1. Create release branch from main
2. Run full test suite
3. Update version numbers
4. Create release notes
5. Deploy to staging
6. Perform smoke tests
7. Deploy to production
8. Monitor for issues

### Rollback Procedure
1. Identify the issue
2. Assess impact and urgency
3. Execute rollback plan
4. Verify system stability
5. Communicate status
6. Plan fix and re-deployment

## Continuous Improvement

### Regular Reviews
- Weekly: Review current sprint progress
- Monthly: Analyze development metrics
- Quarterly: Review and update processes
- Annually: Major architecture review

### Metrics to Track
- Time from requirements to deployment
- Code review cycle time
- Bug discovery rate
- Test coverage percentage
- Performance benchmarks

### Process Optimization
- Regularly update steering documents
- Refine development patterns
- Improve automation
- Enhance monitoring and alerting
- Streamline deployment process