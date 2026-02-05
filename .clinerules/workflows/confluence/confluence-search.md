# Confluence Search Workflow

**Trigger Commands:**
- `confluence search`
- `search confluence`
- `/confluence-search`
- `find confluence page`

**Description:**
Automated workflow for searching Confluence pages in specific project spaces. This workflow streamlines the manual process of finding Confluence documentation by allowing quick searches based on keywords, page titles, or content within designated project spaces.

## Overview

This workflow automates Confluence searches by:
1. Accepting search criteria and project space from the user
2. Constructing appropriate Confluence API queries
3. Executing searches via Confluence REST API
4. Displaying formatted search results with page titles, excerpts, and links

## Prerequisites

### 1. Confluence API Configuration

**Configuration File:**
```
File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json

Required section:
{
  "confluenceConfig": {
    "baseUrl": "https://your-confluence-domain.com",
    "email": "your-email@company.com",
    "apiToken": "your-api-token",
    "defaultSpace": "PROJ"
  }
}
```

**How to get Confluence API token:**
1. Log in to Confluence
2. Go to Account Settings → Security → API tokens
3. Click "Create API token"
4. Copy the token and add to configuration file

### 2. Verify Configuration

**Check configuration file:**
```bash
# View Confluence configuration
cat /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json | jq '.confluenceConfig'
```

**Test API connection:**

**⚠️ IMPORTANT: Unset proxy before making Confluence API calls**

```bash
# ALWAYS unset proxy first for Confluence
unset http_proxy
unset https_proxy

# Load configuration
CONFLUENCE_BASE_URL=$(cat /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json | jq -r '.confluenceConfig.baseUrl')
CONFLUENCE_API_TOKEN=$(cat /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json | jq -r '.confluenceConfig.apiToken')

# Test authentication - Use Bearer token authentication
curl -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_BASE_URL/rest/api/user/current"
```

### 3. Required Permissions

Your Confluence account must have:
- Permission to view pages in the target space
- Access to search functionality
- Read permissions for the content

## Search Types

### 1. Search by Keywords

**Searches page titles and content:**

```bash
# Search for specific keywords
User: confluence search "authentication"
User: search confluence "OAuth integration"
```

### 2. Search in Specific Space

**Limit search to a particular project space:**

```bash
# Search in specific space
User: confluence search "API documentation" in PROJ
User: search confluence "user guide" in MOBILE
```

### 3. Search by Page Title

**Find pages with specific titles:**

```bash
# Search by title
User: confluence search title "Getting Started"
User: find confluence page titled "Architecture Overview"
```

### 4. Search by Label

**Find pages with specific labels:**

```bash
# Search by label
User: confluence search label:api
User: search confluence pages with label authentication
```

### 5. Advanced CQL Search

**Use Confluence Query Language (CQL) for complex searches:**

```bash
# Custom CQL query
User: confluence search "space = PROJ AND type = page AND title ~ 'API'"
```

## Workflow Steps

### Step 1: Load Configuration

**Cline loads Confluence configuration:**

```bash
# File: /Users/[USER_TGI]/Documents/Cline/Settings/cline_workflow_config.json
# Extract: confluenceConfig section
```

**Configuration includes:**
- `baseUrl` - Confluence instance URL
- `email` - User email for authentication
- `apiToken` - API token for authentication
- `defaultSpace` - Default space to search in

### Step 2: Parse Search Criteria

**Cline analyzes the search request and determines:**
- Search keywords or phrase
- Target space (uses default if not specified)
- Search type (content, title, label, or CQL)
- Additional filters

### Step 3: Construct CQL Query

**Based on search criteria, Cline constructs appropriate CQL:**

**Search by Keywords:**
```
space = PROJ AND (title ~ "authentication" OR text ~ "authentication")
```

**Search by Title:**
```
space = PROJ AND title ~ "Getting Started"
```

**Search by Label:**
```
space = PROJ AND label = "api"
```

**Search in Multiple Spaces:**
```
space IN (PROJ, MOBILE) AND text ~ "authentication"
```

**Combined Search:**
```
space = PROJ AND type = page AND title ~ "API" AND label = "documentation"
```

### Step 4: Execute Search via API

**⚠️ IMPORTANT: Always unset proxy before making API calls**

```bash
# ALWAYS unset proxy first
unset http_proxy
unset https_proxy

# Execute search using Bearer token authentication
curl -G "$CONFLUENCE_BASE_URL/rest/api/content/search" \
  -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data-urlencode "cql=$CQL_QUERY" \
  --data-urlencode "limit=25" \
  --data-urlencode "expand=space,version,body.view"
```

**API Parameters:**
- `cql` - The CQL query string
- `limit` - Maximum number of results (default: 25)
- `expand` - Additional fields to return
- `start` - Pagination offset (for large result sets)

### Step 5: Format and Display Results

**Cline displays results in a formatted list:**

```
Found 5 pages in PROJ space:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Getting Started with OAuth Authentication
   Space: PROJ | Last Updated: 2025-01-20
   
   Excerpt: This guide covers the implementation of OAuth 2.0 authentication
   in our mobile applications. It includes setup instructions, code examples,
   and best practices...
   
   URL: https://confluence.example.com/display/PROJ/Getting+Started+with+OAuth

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. API Authentication Documentation
   Space: PROJ | Last Updated: 2025-01-18
   
   Excerpt: Complete reference for all authentication endpoints including
   OAuth, JWT, and API key authentication methods...
   
   URL: https://confluence.example.com/display/PROJ/API+Authentication

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Additional results...]
```

## Usage Examples

### Example 1: Simple Keyword Search

```
User: confluence search "authentication"

Cline: Loading Confluence configuration...
      ✅ Configuration loaded
      
      Searching for "authentication" in default space (PROJ)...
      
      ✅ Found 8 pages:
      
      1. OAuth Authentication Guide
         Last Updated: 2025-01-20
         URL: https://confluence.example.com/display/PROJ/OAuth+Authentication
      
      2. API Authentication Methods
         Last Updated: 2025-01-18
         URL: https://confluence.example.com/display/PROJ/API+Authentication
      
      3. User Authentication Flow
         Last Updated: 2025-01-15
         URL: https://confluence.example.com/display/PROJ/User+Authentication
      
      [5 more results...]
      
      View all results in Confluence:
      https://confluence.example.com/dosearchsite.action?cql=space%3DPROJ...
```

### Example 2: Search in Specific Space

```
User: confluence search "API documentation" in MOBILE

Cline: Searching for "API documentation" in MOBILE space...
      
      ✅ Found 12 pages:
      
      1. Mobile API Documentation
         Space: MOBILE | Last Updated: 2025-01-22
         
         Excerpt: Complete API reference for mobile applications including
         authentication, data sync, and push notifications...
         
         URL: https://confluence.example.com/display/MOBILE/Mobile+API
      
      2. REST API Endpoints
         Space: MOBILE | Last Updated: 2025-01-20
         
         Excerpt: Detailed documentation of all REST API endpoints available
         for mobile clients...
         
         URL: https://confluence.example.com/display/MOBILE/REST+API
      
      [10 more results...]
```

### Example 3: Search by Title

```
User: confluence search title "Getting Started"

Cline: Searching for pages titled "Getting Started"...
      
      ✅ Found 3 pages:
      
      1. Getting Started with OAuth
         Space: PROJ | Last Updated: 2025-01-20
         URL: https://confluence.example.com/display/PROJ/Getting+Started+OAuth
      
      2. Getting Started Guide
         Space: MOBILE | Last Updated: 2025-01-15
         URL: https://confluence.example.com/display/MOBILE/Getting+Started
      
      3. Getting Started - Developer Setup
         Space: DEV | Last Updated: 2025-01-10
         URL: https://confluence.example.com/display/DEV/Getting+Started+Setup
```

### Example 4: Search with Label

```
User: confluence search label:api in PROJ

Cline: Searching for pages with label "api" in PROJ space...
      
      ✅ Found 15 pages with label "api":
      
      1. API Authentication Guide
         Labels: api, authentication, security
         Last Updated: 2025-01-20
         URL: https://confluence.example.com/display/PROJ/API+Auth
      
      2. REST API Reference
         Labels: api, rest, documentation
         Last Updated: 2025-01-18
         URL: https://confluence.example.com/display/PROJ/REST+API
      
      [13 more results...]
```

### Example 5: Advanced CQL Search

```
User: confluence search "space = PROJ AND type = page AND title ~ 'API' AND created >= '2025-01-01'"

Cline: Executing custom CQL query...
      
      ✅ Found 6 pages:
      
      1. API Authentication Methods
         Created: 2025-01-15 | Last Updated: 2025-01-20
         URL: https://confluence.example.com/display/PROJ/API+Auth
      
      2. API Rate Limiting
         Created: 2025-01-10 | Last Updated: 2025-01-18
         URL: https://confluence.example.com/display/PROJ/API+Rate+Limiting
      
      [4 more results...]
```

### Example 6: Search Multiple Spaces

```
User: confluence search "deployment guide" in PROJ,MOBILE,DEV

Cline: Searching for "deployment guide" in spaces: PROJ, MOBILE, DEV...
      
      ✅ Found 9 pages across 3 spaces:
      
      PROJ Space (3 results):
      1. Production Deployment Guide
         URL: https://confluence.example.com/display/PROJ/Deployment
      
      MOBILE Space (4 results):
      2. Mobile App Deployment
         URL: https://confluence.example.com/display/MOBILE/Deployment
      
      DEV Space (2 results):
      3. Development Environment Setup
         URL: https://confluence.example.com/display/DEV/Dev+Setup
      
      [6 more results...]
```

## Common Search Patterns

### 1. Documentation Search

```bash
# Find all documentation pages
confluence search "documentation" in PROJ

# Find API docs
confluence search label:api-docs

# Find user guides
confluence search title "User Guide"
```

### 2. Recent Updates

```bash
# Pages updated in last 7 days
confluence search "space = PROJ AND lastModified >= now('-7d')"

# Pages created this month
confluence search "space = PROJ AND created >= startOfMonth()"
```

### 3. By Author

```bash
# Pages by specific author
confluence search "space = PROJ AND creator = 'john.doe'"

# Pages last modified by user
confluence search "space = PROJ AND contributor = 'jane.smith'"
```

### 4. By Content Type

```bash
# Only pages (not blog posts)
confluence search "space = PROJ AND type = page"

# Only blog posts
confluence search "space = PROJ AND type = blogpost"
```

### 5. Architecture and Design

```bash
# Architecture documentation
confluence search "architecture" in PROJ

# Design documents
confluence search label:design

# Technical specifications
confluence search "technical specification"
```

## CQL Quick Reference

### Basic Operators

```
=     equals
!=    not equals
>     greater than
>=    greater than or equals
<     less than
<=    less than or equals
~     contains (text search)
!~    does not contain
IN    in list
NOT IN not in list
```

### Common Fields

```
space           Space key
type            Content type (page, blogpost)
title           Page title
text            Page content
label           Page labels
creator         Page creator
contributor     Page contributor
created         Creation date
lastModified    Last modification date
ancestor        Parent page
```

### Functions

```
currentUser()           Current logged-in user
now()                   Current date/time
startOfDay()            Start of today
endOfDay()              End of today
startOfWeek()           Start of current week
startOfMonth()          Start of current month
```

### Date Formats

```
now('-7d')              7 days ago
now('-1w')              1 week ago
now('-1M')              1 month ago
'2025-01-15'            Specific date
```

### Logical Operators

```
AND                     Both conditions must be true
OR                      Either condition must be true
NOT                     Negates condition
()                      Groups conditions
```

## Advanced Search Examples

### Example 1: Recent Documentation

```cql
space = PROJ AND type = page AND label = "documentation" AND lastModified >= now('-30d') ORDER BY lastModified DESC
```

### Example 2: API Pages by Author

```cql
space = PROJ AND title ~ "API" AND creator = "john.doe" ORDER BY created DESC
```

### Example 3: Pages with Multiple Labels

```cql
space = PROJ AND label IN ("api", "authentication", "security") ORDER BY title ASC
```

### Example 4: Child Pages of Specific Parent

```cql
space = PROJ AND ancestor = "123456" ORDER BY title ASC
```

### Example 5: Recently Updated by Team

```cql
space IN (PROJ, MOBILE) AND contributor IN ("john.doe", "jane.smith") AND lastModified >= now('-7d')
```

## Search Result Formats

### Compact Format (Default)

```
Found 5 pages:

1. OAuth Authentication Guide [PROJ] - Updated: 2025-01-20
2. API Documentation [PROJ] - Updated: 2025-01-18
3. User Guide [MOBILE] - Update
