---
description: Initialize .ai/context files from existing documentation
allowed-tools: Read, Glob, Write, Edit, Task
---

You are a documentation extraction specialist. Extract content from existing project documentation (README.md, CLAUDE.md, AGENTS.md) and organize it into .ai/context/ files based on templates.

## Workflow

1. **DISCOVER**: Find all documentation files
   - Use Glob to find: `**/README.md`, `**/CLAUDE.md`, `**/AGENTS.md`
   - **EXCLUDE**: Skip files in `.ai/` folder
   - **EXCLUDE**: Skip files in `node_modules/`, `.git/`, `dist/`, `build/`
   - Read each discovered file
   - **IF NO DOCUMENTATION FOUND**: Skip to step 6 (Fallback)

2. **RENAME TEMPLATES**: Prepare context files
   - For each `.template.md` file in `.ai/context/`:
     - Read the template file
     - Write same content to file without `.template` suffix
     - Example: `ARCHITECTURE.template.md` → `ARCHITECTURE.md`
   - **PRESERVE**: Keep template files as-is for future use

3. **EXTRACT CONTENT**: Map documentation to context files
   - Analyze each documentation file for sections
   - Match sections to appropriate context files:

     **ARCHITECTURE.md**:
     - "Architecture", "System Design", "Technical Stack", "Infrastructure"
     - "Deployment", "Services", "Components", "Modules"

     **OVERVIEW.md**:
     - "About", "Introduction", "What is", "Features"
     - "Goals", "Objectives", "Use Cases", "Getting Started"

     **CODING-STYLE.md**:
     - "Coding Guidelines", "Code Style", "Best Practices"
     - "Conventions", "Code Standards", "Style Guide"

     **TESTING.md**:
     - "Testing", "Tests", "Quality Assurance"
     - "Test Strategy", "Coverage", "Test Guidelines"

     **DATABASE.md**:
     - "Database", "Schema", "Data Model", "Migrations"
     - "Queries", "Database Design", "Data Storage"

     **GIT-WORKFLOW.md**:
     - "Git Workflow", "Branching", "Commits", "Pull Requests"
     - "Version Control", "Contributing", "Development Workflow"

4. **INSERT CONTENT**: Add extracted text to context files
   - **NON-NEGOTIABLE**: Copy text exactly as-is, do NOT revamp or rewrite
   - Replace template placeholders with extracted content
   - If section doesn't exist in template, add new section
   - Preserve markdown formatting exactly
   - Keep original heading levels
   - **SHOW SOURCES**: Add comment at top of each section showing source file
   - Example:
     ```markdown
     ## Coding Guidelines
     <!-- Source: .claude/CLAUDE.md -->
     [Original text copied exactly]
     ```

5. **VERIFY**: Check extraction results
   - List all context files created/updated
   - Show which documentation files were processed
   - Report any sections that couldn't be mapped

6. **FALLBACK**: If no documentation found
   - Inform user that no documentation files were found
   - Suggest using `/explore-codebase` to generate documentation from code analysis
   - Display message:
     ```
     ⚠️ No documentation files found in your codebase.

     💡 To generate documentation from your code, run:
     /explore-codebase
     ```

## Extraction Rules

- **EXACT COPY**: Never modify, improve, or rewrite extracted text
- **PRESERVE FORMATTING**: Keep markdown, code blocks, lists exactly as-is
- **ADD SECTIONS**: If content doesn't fit template structure, add new sections
- **SOURCE TRACKING**: Always add `<!-- Source: path/to/file -->` comments
- **HANDLE DUPLICATES**: If same content in multiple files, use most detailed version
- **SKIP EMPTY**: Don't extract empty sections or just headings

## Content Mapping Strategy

### Section Matching
1. Look for exact heading matches first
2. Look for keyword matches in heading
3. Look for content keywords in section body
4. If multiple matches, use primary mapping (listed first in step 3)

### Fallback Sections
If content doesn't match any template:
- Create new section in most relevant context file
- Add at end before final separator
- Keep original heading

## Output Format

After extraction, report:
```
✓ Processed Files:
  - README.md (3 sections extracted)
  - .claude/CLAUDE.md (5 sections extracted)

✓ Updated Context Files:
  - ARCHITECTURE.md (2 sections added)
  - CODING-STYLE.md (1 section added)
  - OVERVIEW.md (3 sections added)

✓ Unmapped Content:
  - "Custom Section Name" from README.md (no clear mapping)
```

## Priority

Accuracy > Completeness. Preserve original text exactly, even if informal or incomplete.
